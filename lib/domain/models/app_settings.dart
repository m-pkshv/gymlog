/// The singleton app settings row (06_DATA_MODEL.md, section 6.12).
/// Deliberately minimal for now — only [showTags] (Stage 3: "settings
/// (только флаг showTags)"). The other columns already exist in the table
/// (unitSystem/theme/locale/defaultRestTimerSec/restTimerAutoStart) and get
/// their own domain fields once a feature actually needs to read/write them
/// (Stage 9, full settings screen).
class AppSettings {
  const AppSettings({required this.showTags, required this.updatedAt});

  final bool showTags;
  final DateTime updatedAt;
}
