import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/domain/repositories/user_profile_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gymlog/services/user_profile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockUserProfileRepository repository;
  late MockImagePicker picker;
  late UserProfileService service;

  setUp(() {
    repository = MockUserProfileRepository();
    picker = MockImagePicker();
    service = UserProfileService(repository, picker);
    when(() => repository.setNickname(any())).thenAnswer((_) async {});
    when(() => repository.setFirstName(any())).thenAnswer((_) async {});
    when(() => repository.setLastName(any())).thenAnswer((_) async {});
    when(() => repository.setAvatarPath(any())).thenAnswer((_) async {});
  });

  group('updateProfile', () {
    test('trims whitespace and writes each field', () async {
      final result = await service.updateProfile(
        nickname: '  Max  ',
        firstName: ' Maksim ',
        lastName: ' Pekshev ',
      );

      expect(result.isOk, isTrue);
      verify(() => repository.setNickname('Max')).called(1);
      verify(() => repository.setFirstName('Maksim')).called(1);
      verify(() => repository.setLastName('Pekshev')).called(1);
    });

    test('normalizes an empty/whitespace-only value to null', () async {
      final result = await service.updateProfile(
        nickname: '   ',
        firstName: null,
        lastName: '',
      );

      expect(result.isOk, isTrue);
      verify(() => repository.setNickname(null)).called(1);
      verify(() => repository.setFirstName(null)).called(1);
      verify(() => repository.setLastName(null)).called(1);
    });

    test('accepts a name at exactly 60 characters', () async {
      final name = 'a' * 60;
      final result = await service.updateProfile(nickname: name);

      expect(result.isOk, isTrue);
      verify(() => repository.setNickname(name)).called(1);
    });

    test('rejects a name over 60 characters without writing anything', () async {
      final name = 'a' * 61;
      final result = await service.updateProfile(nickname: name);

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      verifyNever(() => repository.setNickname(any()));
    });
  });

  group('pickAndSetAvatar', () {
    late Directory tempDir;
    late File sourceImage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gymlog_profile_test_');
      sourceImage = File('${tempDir.path}/source.jpg');
      await sourceImage.writeAsBytes([1, 2, 3, 4]);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('copies the picked image into the storage directory and stores '
        'its path', () async {
      when(
        () => picker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => XFile(sourceImage.path));
      final storageDir = Directory('${tempDir.path}/profile');

      final result = await service.pickAndSetAvatar(
        storageDirectory: storageDir,
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull(), isTrue);
      final expectedPath =
          '${storageDir.path}/${UserProfileService.avatarFileName}';
      expect(await File(expectedPath).exists(), isTrue);
      expect(await File(expectedPath).readAsBytes(), [1, 2, 3, 4]);
      verify(() => repository.setAvatarPath(expectedPath)).called(1);
    });

    test('returns Ok(false) without writing anything if the user cancels', () async {
      when(
        () => picker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      final result = await service.pickAndSetAvatar(
        storageDirectory: Directory('${tempDir.path}/profile'),
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull(), isFalse);
      verifyNever(() => repository.setAvatarPath(any()));
    });
  });

  group('removeAvatar', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gymlog_profile_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deletes the existing avatar file and clears the stored path', () async {
      final avatarFile = File('${tempDir.path}/avatar.jpg');
      await avatarFile.writeAsBytes([1, 2, 3]);

      await service.removeAvatar(avatarFile.path);

      expect(await avatarFile.exists(), isFalse);
      verify(() => repository.setAvatarPath(null)).called(1);
    });

    test('is a no-op on disk when there was no avatar path', () async {
      await service.removeAvatar(null);

      verify(() => repository.setAvatarPath(null)).called(1);
    });
  });
}
