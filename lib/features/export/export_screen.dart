import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/import_export_operation.dart';
import '../../l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final journalAsync = ref.watch(importExportOperationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
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
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.exportFormatHelpAction),
            onTap: () => context.push('/more/export/format'),
          ),
          const Divider(height: 1),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.file_download_outlined),
            title: Text(l10n.importAction),
            subtitle: Text(l10n.importComingSoonLabel),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.exportJournalTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          journalAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.exportJournalEmpty),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (final entry in entries) _JournalRow(entry: entry),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(l10n.exportJournalLoadError),
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
