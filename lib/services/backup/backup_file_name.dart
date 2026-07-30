/// `gymlog_backup_YYYY-MM-DD_HHmm.zip`, from the local backup time --
/// locale-independent, mirroring `services/export/export_file_name.dart`'s
/// CSV export naming.
String backupZipFileName(DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return 'gymlog_backup_$y-$m-${d}_$hh$mm.zip';
}
