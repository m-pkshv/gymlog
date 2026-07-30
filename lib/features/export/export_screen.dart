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
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/grouped_section.dart';
import '../../data/database.dart' hide ImportExportOperation;
import '../../domain/enums.dart';
import '../../domain/models/import_export_operation.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup/backup_manifest.dart';
import 'restart_required_screen.dart';

/// S-16 "Импорт/экспорт" (04_UI_UX_SPEC.md, section 5): the export button
/// + progress, the operations journal, the disabled "Импорт" stub
/// (post-MVP, TS 10.6), and a link to the format help screen.
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
    final journalAsync = ref.watch(importExportOperationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Full-width: this screen's one primary action, same weight as
          // other screens' single dominant CTA (Stage 10 redesign).
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
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
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                enabled: false,
                leading: const Icon(Icons.file_download_outlined),
                title: Text(l10n.importAction),
                subtitle: Text(l10n.importComingSoonLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GroupedSection(
            title: l10n.backupSectionTitle,
            children: [
              ListTile(
                leading: _isExportingBackup
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup_outlined),
                title: Text(l10n.backupExportAction),
                enabled: !_isExportingBackup && !_isRestoringBackup,
                onTap: _exportBackup,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: _isRestoringBackup
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.settings_backup_restore),
                title: Text(l10n.backupRestoreAction),
                enabled: !_isExportingBackup && !_isRestoringBackup,
                onTap: _restoreBackup,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GroupedSection(
            title: l10n.exportJournalTitle,
            children: [
              journalAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(l10n.exportJournalEmpty),
                    );
                  }
                  return Column(
                    children: [
                      for (final entry in entries) _JournalRow(entry: entry),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => ErrorRetryState(
                  message: l10n.exportJournalLoadError,
                  onRetry: () =>
                      ref.invalidate(importExportOperationsProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.entry});

  final ImportExportOperation entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, statusLabel) = switch (entry.status) {
      ImportExportOperationStatus.inProgress => (
        Icons.hourglass_empty,
        l10n.exportStatusInProgress,
      ),
      ImportExportOperationStatus.success => (
        Icons.check_circle_outline,
        l10n.exportStatusSuccess,
      ),
      ImportExportOperationStatus.failed => (
        Icons.error_outline,
        l10n.exportStatusFailed,
      ),
    };
    final counts = entry.itemCounts;
    final subtitle = counts == null
        ? statusLabel
        : '$statusLabel · ${l10n.exportJournalCounts(counts.workouts, counts.sets, counts.measurements, counts.exercises)}';

    final local = entry.startedAt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');

    return ListTile(
      leading: Icon(icon),
      title: Text('${formatShortDate(local)} $hh:$mm'),
      subtitle: Text(subtitle),
    );
  }
}
