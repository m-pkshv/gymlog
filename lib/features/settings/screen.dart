import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// S-17 settings screen (04_UI_UX_SPEC.md, section 5). Stage 9, step 4:
/// theme + language selectors, unit system/"show tags" (moved here from the
/// temporary switches on the "More" placeholder,
/// `ASSUMPTION(temp-show-tags-toggle)` / `ASSUMPTION(temp-unit-system-toggle)`,
/// resolved at step 1), default rest-timer seconds/auto-start (backend from
/// Stage 4, TS 7.1/7.2), and the notifications status row + link to the OS
/// settings screen. "About" lands in a later step of this stage.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _SegmentedSection<AppTheme>(
              label: l10n.settingsThemeLabel,
              segments: {
                AppTheme.system: l10n.settingsThemeSystem,
                AppTheme.light: l10n.settingsThemeLight,
                AppTheme.dark: l10n.settingsThemeDark,
              },
              selected: settings.theme,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setTheme(value),
            ),
            _SegmentedSection<AppLocale>(
              label: l10n.settingsLanguageLabel,
              segments: {
                AppLocale.system: l10n.settingsLanguageSystem,
                AppLocale.ru: l10n.settingsLanguageRu,
                AppLocale.en: l10n.settingsLanguageEn,
              },
              selected: settings.locale,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setLocale(value),
            ),
            const Divider(height: 33),
            SwitchListTile(
              title: Text(l10n.settingsShowTagsLabel),
              value: settings.showTags,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setShowTags(value),
            ),
            SwitchListTile(
              title: Text(l10n.settingsUnitSystemLabel),
              subtitle: Text(
                settings.unitSystem == UnitSystem.imperial
                    ? l10n.settingsUnitSystemImperial
                    : l10n.settingsUnitSystemMetric,
              ),
              value: settings.unitSystem == UnitSystem.imperial,
              onChanged: (imperial) => ref
                  .read(appSettingsRepositoryProvider)
                  .setUnitSystem(
                    imperial ? UnitSystem.imperial : UnitSystem.metric,
                  ),
            ),
            const Divider(height: 33),
            _RestTimerSecondsField(value: settings.defaultRestTimerSec),
            SwitchListTile(
              title: Text(l10n.settingsRestTimerAutoStartLabel),
              value: settings.restTimerAutoStart,
              onChanged: (value) => ref
                  .read(appSettingsRepositoryProvider)
                  .setRestTimerAutoStart(value),
            ),
            const Divider(height: 33),
            const _NotificationsSection(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.settingsLoadError)),
      ),
    );
  }
}

/// A labeled `SegmentedButton` (used for both theme and language on this
/// screen — same shape, different enum). `segments` gives each value its
/// label, in display order.
class _SegmentedSection<T extends Object> extends StatelessWidget {
  const _SegmentedSection({
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<T>(
            segments: [
              for (final entry in segments.entries)
                ButtonSegment(value: entry.key, label: Text(entry.value)),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (selected) => onChanged(selected.first),
          ),
        ),
      ],
    );
  }
}

/// The default-rest-timer-seconds field (DM 6.12, Q-4: 10-600). Same
/// resync-while-unfocused mechanics as `SetNumberField`/`CommentField`
/// (03_TECHNICAL_SPEC.md, section 5) — an in-flight edit is never clobbered
/// by a settings-stream rebuild — but with its own inline range error,
/// since `AppSettingsService.setDefaultRestTimerSec` can reject the value.
class _RestTimerSecondsField extends ConsumerStatefulWidget {
  const _RestTimerSecondsField({required this.value});

  final int value;

  @override
  ConsumerState<_RestTimerSecondsField> createState() =>
      _RestTimerSecondsFieldState();
}

class _RestTimerSecondsFieldState
    extends ConsumerState<_RestTimerSecondsField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _RestTimerSecondsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = widget.value.toString();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  Future<void> _commit() async {
    final l10n = AppLocalizations.of(context)!;
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      setState(() => _error = l10n.settingsRestTimerRangeError);
      return;
    }
    final result = await ref
        .read(appSettingsServiceProvider)
        .setDefaultRestTimerSec(parsed);
    if (!mounted) return;
    setState(
      () => _error = result.fold(
        (_) => null,
        (_) => l10n.settingsRestTimerRangeError,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.settingsRestTimerLabel,
          errorText: _error,
        ),
        onSubmitted: (_) => _commit(),
      ),
    );
  }
}

/// Notifications status + "open OS settings" link (S-17, 04_UI_UX_SPEC.md,
/// section 5). Reuses `notificationsEnabledProvider`, the same one already
/// driving the "Уведомления выключены" hint on the in-workout rest-timer
/// bar (Stage 4, TS 7.3) -- one source of truth for the enabled/disabled
/// status, not a second poll of the plugin.
class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  Future<void> _openSettings(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    var opened = false;
    try {
      opened = await ref
          .read(notificationServiceProvider)
          .openNotificationSettings();
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to open notification settings',
            error: error,
            stackTrace: stackTrace,
          );
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsNotificationsOpenSettingsError)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref
        .watch(notificationsEnabledProvider)
        .maybeWhen(data: (value) => value, orElse: () => true);
    return ListTile(
      title: Text(l10n.settingsNotificationsLabel),
      subtitle: Text(
        enabled
            ? l10n.settingsNotificationsEnabled
            : l10n.settingsNotificationsDisabled,
      ),
      trailing: TextButton(
        onPressed: () => _openSettings(context, ref),
        child: Text(l10n.settingsNotificationsOpenSettingsAction),
      ),
    );
  }
}
