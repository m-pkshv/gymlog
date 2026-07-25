import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../core/widgets/grouped_section.dart';
import '../../l10n/app_localizations.dart';

/// S-11 "Ещё" (04_UI_UX_SPEC.md, section 5) — menu to templates/tags/
/// measurements/import-export/settings.
///
/// Stage 10 redesign, AUDIT.md section 1.5: "a plain settings-list with no
/// subtitles/descriptions, no grouping by meaning (data management vs
/// configuration) -- indistinguishable from the default Material
/// template". Grouped into two titled sections (data-management items,
/// then the one configuration item) with a one-line description under
/// each, following AUDIT's own suggested split.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GroupedSection(
            title: l10n.moreSectionData,
            children: [
              _MoreListTile(
                icon: Icons.copy_all_outlined,
                title: l10n.templatesTitle,
                subtitle: l10n.moreTemplatesSubtitle,
                onTap: () => context.push('/more/templates'),
              ),
              _MoreListTile(
                icon: Icons.label_outline,
                title: l10n.tagsMenuTitle,
                subtitle: l10n.moreTagsSubtitle,
                onTap: () => context.push('/more/tags'),
              ),
              _MoreListTile(
                icon: Icons.monitor_weight_outlined,
                title: l10n.measurementsTitle,
                subtitle: l10n.moreMeasurementsSubtitle,
                onTap: () => context.push('/more/measurements'),
              ),
              _MoreListTile(
                icon: Icons.import_export_outlined,
                title: l10n.exportScreenTitle,
                subtitle: l10n.moreExportSubtitle,
                onTap: () => context.push('/more/export'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GroupedSection(
            title: l10n.moreSectionConfiguration,
            children: [
              _MoreListTile(
                icon: Icons.settings_outlined,
                title: l10n.settingsTitle,
                subtitle: l10n.moreSettingsSubtitle,
                onTap: () => context.push('/more/settings'),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreListTile extends StatelessWidget {
  const _MoreListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Rows within a section card share one boundary, not each their own --
  /// only inner rows get a bottom divider.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
