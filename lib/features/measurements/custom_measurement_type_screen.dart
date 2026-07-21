import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/measurement_type.dart';
import '../../l10n/app_localizations.dart';
import 'measurement_type_labels.dart';
import 'widgets/measurement_type_detail.dart';

enum _MeasurementTypeAction { archive, unarchive, delete }

/// Detail screen for one custom `MeasurementType` (S-14 "Свои" tab):
/// chart + entries (`MeasurementTypeDetail`) plus the DM 10 archive/delete
/// menu, mirroring `ExerciseDetailScreen`'s pattern for the exercise
/// catalog. Built-in types never reach this screen (they have no archive/
/// delete UI at all, `ASSUMPTION(builtin-types-not-archivable)`).
class CustomMeasurementTypeScreen extends ConsumerStatefulWidget {
  const CustomMeasurementTypeScreen({super.key, required this.typeId});

  final String typeId;

  @override
  ConsumerState<CustomMeasurementTypeScreen> createState() =>
      _CustomMeasurementTypeScreenState();
}

class _CustomMeasurementTypeScreenState
    extends ConsumerState<CustomMeasurementTypeScreen> {
  MeasurementType? _type;
  bool _isLoading = true;
  bool _loadError = false;
  bool _canDelete = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final type = await ref
          .read(measurementTypeRepositoryProvider)
          .getById(widget.typeId);
      final canDelete = type == null
          ? false
          : await ref.read(measurementTypeServiceProvider).canDelete(type);
      if (!mounted) return;
      setState(() {
        _type = type;
        _canDelete = canDelete;
        _isLoading = false;
        _loadError = type == null;
      });
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to load measurement type ${widget.typeId}',
            error: error,
            stackTrace: stackTrace,
          );
      if (mounted) setState(() => _loadError = true);
    }
  }

  Future<void> _archive({required bool archived}) async {
    final type = _type;
    if (type == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isBusy = true);
    final service = ref.read(measurementTypeServiceProvider);
    final result = archived
        ? await service.archive(type)
        : await service.unarchive(type);
    if (!mounted) return;
    result.fold((updated) => setState(() => _type = updated), (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.archiveMeasurementTypeError)));
    });
    setState(() => _isBusy = false);
  }

  Future<void> _confirmDelete() async {
    final type = _type;
    if (type == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMeasurementTypeConfirmTitle),
        content: Text(l10n.deleteMeasurementTypeConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteMeasurementTypeAction,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    final result = await ref.read(measurementTypeServiceProvider).delete(type);
    if (!mounted) return;
    result.fold((_) => context.pop(), (_) {
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteMeasurementTypeError)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = _type;

    return Scaffold(
      appBar: AppBar(
        title: Text(type == null ? '' : measurementTypeLabel(l10n, type)),
        actions: type == null
            ? null
            : [
                PopupMenuButton<_MeasurementTypeAction>(
                  enabled: !_isBusy,
                  onSelected: (action) {
                    switch (action) {
                      case _MeasurementTypeAction.archive:
                        _archive(archived: true);
                      case _MeasurementTypeAction.unarchive:
                        _archive(archived: false);
                      case _MeasurementTypeAction.delete:
                        _confirmDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: type.isArchived
                          ? _MeasurementTypeAction.unarchive
                          : _MeasurementTypeAction.archive,
                      child: Text(
                        type.isArchived
                            ? l10n.unarchiveMeasurementTypeAction
                            : l10n.archiveMeasurementTypeAction,
                      ),
                    ),
                    if (_canDelete)
                      PopupMenuItem(
                        value: _MeasurementTypeAction.delete,
                        child: Text(l10n.deleteMeasurementTypeAction),
                      ),
                  ],
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_loadError || type == null)
          ? Center(child: Text(l10n.measurementsLoadError))
          : MeasurementTypeDetail(type: type),
      floatingActionButton: type == null
          ? null
          : FloatingActionButton(
              onPressed: () =>
                  context.push('/more/measurements/new', extra: type.id),
              tooltip: l10n.addMeasurementEntryAction,
              child: const Icon(Icons.add),
            ),
    );
  }
}
