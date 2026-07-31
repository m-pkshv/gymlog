import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/grouped_section.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup/backup_manifest.dart';
import 'restart_required_screen.dart';

/// S-16 "Резервная копия" (04_UI_UX_SPEC.md, section 5; renamed from
/// "Импорт/экспорт" Stage 11, owner-reported: the whole-database backup is
/// this screen's primary function, CSV export is secondary -- "Бэкап" was
/// tried first, then replaced with the more formal RU term) -- the backup
/// export/restore buttons (moved above the CSV section, separated from it
/// by a divider), the CSV export button + progress, and a link to the
/// format help screen. The disabled "Импорт" stub (post-MVP, TS 10.6) and
/// the operations journal were both removed outright rather than kept as
/// placeholders/dead weight (owner-reported: no user-facing value).
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;
  bool _isExportingBackup = false;
  bool _isRestoringBackup = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final outputDirectory = await getTemporaryDirectory();
      final file = await ref
          .read(exportServiceProvider)
          .export(outputDirectory: outputDirectory);
      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error('Export failed', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportBackup() async {
    setState(() => _isExportingBackup = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final databaseFile = await resolveDatabaseFile();
      final outputDirectory = await getTemporaryDirectory();
      final file = await ref
          .read(backupServiceProvider)
          .exportBackup(
            db: db,
            databaseFile: databaseFile,
            outputDirectory: outputDirectory,
          );
      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error('Backup export failed', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportError)));
    } finally {
      if (mounted) setState(() => _isExportingBackup = false);
    }
  }

  /// Picks a backup ZIP, validates it, asks for destructive confirmation,
  /// then closes the live DB connection and overwrites the file --
  /// irreversible, and the app can't keep running normally afterward (the
  /// closed connection is gone for good), so a successful restore replaces
  /// the whole navigation stack with [RestartRequiredScreen] instead of
  /// returning here (owner-confirmed 2026-07-30).
  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (picked?.path == null) return;
    final zipFile = File(picked!.path!);

    setState(() => _isRestoringBackup = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final BackupManifest manifest;
      try {
        manifest = await backupService.inspectBackup(zipFile);
      } on FormatException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreInvalidFileError)),
        );
        return;
      }

      final db = ref.read(appDatabaseProvider);
      if (manifest.schemaVersion > db.schemaVersion) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreNewerSchemaError)),
        );
        return;
      }

      if (!mounted) return;
      final local = manifest.createdAtUtc.toLocal();
      final hh = local.hour.toString().padLeft(2, '0');
      final mm = local.minute.toString().padLeft(2, '0');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.backupRestoreConfirmTitle),
          content: Text(
            l10n.backupRestoreConfirmMessage('${formatShortDate(local)} $hh:$mm'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.backupRestoreConfirmAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final databaseFile = await resolveDatabaseFile();
      await db.close();
      await backupService.restoreBackup(
        zipFile: zipFile,
        databaseFile: databaseFile,
      );

      if (!mounted) return;
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RestartRequiredScreen()),
        (route) => false,
      );
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Backup restore failed',
            error: error,
            stackTrace: stackTrace,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreError)));
    } finally {
      if (mounted) setState(() => _isRestoringBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final busyWithBackup = _isExportingBackup || _isRestoringBackup;
    // Matches the app-wide "big primary CTA" convention (e.g.
    // _StatusCtaButton in workout_editor/screen.dart) rather than the
    // default FilledButton size -- applied to all three full-width buttons
    // on this screen so they read as one consistent size, not just the
    // backup ones sticking out (owner-reported: "сделаем их больше").
    const bigButtonPadding = EdgeInsets.symmetric(vertical: 14);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Backup first (owner-reported: it's this screen's primary
          // function, CSV export is secondary) -- export in the app's
          // ordinary primary blue, restore in the accent color already used
          // elsewhere for "important, higher-stakes" CTAs (finishing a
          // workout, the rest timer), since restoring irreversibly
          // overwrites the whole database.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(padding: bigButtonPadding),
              onPressed: busyWithBackup ? null : _exportBackup,
              icon: _isExportingBackup
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup_outlined),
              label: Text(l10n.backupExportAction),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: semantic.accent,
                foregroundColor: semantic.onAccent,
                padding: bigButtonPadding,
              ),
              onPressed: busyWithBackup ? null : _restoreBackup,
              icon: _isRestoringBackup
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: semantic.onAccent,
                      ),
                    )
                  : const Icon(Icons.settings_backup_restore),
              label: Text(l10n.backupRestoreAction),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Owner-reported: a visual divider between the two backup
          // buttons and the CSV export/format-description block below,
          // so the two functions of this screen read as clearly separate.
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(padding: bigButtonPadding),
              onPressed: _isExporting ? null : _export,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(l10n.exportAction),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GroupedSection(
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.exportFormatHelpAction),
                onTap: () => context.push('/more/export/format'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
