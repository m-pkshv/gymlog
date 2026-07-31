/// `ironbook_export_YYYY-MM-DD_HHmm.zip` (03_TECHNICAL_SPEC.md, section
/// 10.1), from the local export time -- locale-independent. Prefix renamed
/// from `gymlog_` (Q-2, owner-confirmed 2026-07-31) -- user-visible.
String exportZipFileName(DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return 'ironbook_export_$y-$m-${d}_$hh$mm.zip';
}
