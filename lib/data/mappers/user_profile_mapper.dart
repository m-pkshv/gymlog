import '../../domain/models/user_profile.dart';
import '../database.dart' as drift;

extension UserProfileRowMapper on drift.UserProfileRow {
  UserProfile toDomain() {
    return UserProfile(
      nickname: nickname,
      firstName: firstName,
      lastName: lastName,
      avatarPath: avatarPath,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
