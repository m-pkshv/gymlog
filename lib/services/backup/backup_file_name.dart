/// `ironbook_backup_YYYY-MM-DD_HHmm.zip`, from the local backup time --
/// locale-independent, mirroring `services/export/export_file_name.dart`'s
/// CSV export naming. Prefix renamed from `gymlog_` (Q-2, owner-confirmed
/// 2026-07-31) -- this is a user-visible file name (seen when saving/
/// sharing the backup), unlike the internal `gymlog.sqlite` DB file name
/// or the `GymLogApp` Dart class, which the owner chose to leave as-is.
String backupZipFileName(DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return 'ironbook_backup_$y-$m-${d}_$hh$mm.zip';
}
