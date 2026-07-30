/// The singleton user profile row (06_DATA_MODEL.md, section 6.15, Stage
/// 11) -- nickname/first/last name and a path to a locally-copied avatar
/// image, used to personalize a future PDF workout export.
class UserProfile {
  const UserProfile({
    required this.nickname,
    required this.firstName,
    required this.lastName,
    required this.avatarPath,
    required this.updatedAt,
  });

  final String? nickname;
  final String? firstName;
  final String? lastName;
  final String? avatarPath;
  final DateTime updatedAt;
}
