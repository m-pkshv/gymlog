/// `gymlog_export_YYYY-MM-DD_HHmm.zip` (03_TECHNICAL_SPEC.md, section
/// 10.1), from the local export time -- locale-independent.
String exportZipFileName(DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return 'gymlog_export_$y-$m-${d}_$hh$mm.zip';
}
