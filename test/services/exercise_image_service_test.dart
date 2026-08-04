import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/exercise_image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker picker;
  late ExerciseImageService service;
  late Directory tempDir;

  setUp(() async {
    picker = MockImagePicker();
    service = ExerciseImageService(picker);
    tempDir = await Directory.systemTemp.createTemp(
      'gymlog_exercise_image_test_',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('pickBytes', () {
    test('returns Ok(null) when the user cancels the picker', () async {
      when(
        () => picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 256,
          maxHeight: 256,
          imageQuality: 85,
        ),
      ).thenAnswer((_) async => null);

      final result = await service.pickBytes(
        source: ImageSource.gallery,
        maxDimensionPx: 256,
        qualityPercent: 85,
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull(), isNull);
    });

    test('returns the picked bytes with the given caps', () async {
      final sourceFile = File('${tempDir.path}/picked.jpg')
        ..writeAsBytesSync([1, 2, 3, 4]);
      when(
        () => picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        ),
      ).thenAnswer((_) async => XFile(sourceFile.path));

      final result = await service.pickBytes(
        source: ImageSource.camera,
        maxDimensionPx: 1024,
        qualityPercent: 85,
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull(), [1, 2, 3, 4]);
    });

    test('returns Err on an unexpected picker failure', () async {
      when(
        () => picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await service.pickBytes(
        source: ImageSource.gallery,
        maxDimensionPx: 256,
        qualityPercent: 85,
      );

      expect(result.isErr, isTrue);
    });
  });

  group('writeIcon / writeImage', () {
    test('writes bytes under a fixed per-exercise icon file name', () async {
      final path = await service.writeIcon(
        tempDir,
        'ex1',
        Uint8List.fromList([9, 9, 9]),
      );

      expect(path, '${tempDir.path}/ex1_icon.jpg');
      expect(await File(path).readAsBytes(), [9, 9, 9]);
    });

    test('writes bytes under a fixed per-exercise photo file name', () async {
      final path = await service.writeImage(
        tempDir,
        'ex1',
        Uint8List.fromList([7, 7, 7]),
      );

      expect(path, '${tempDir.path}/ex1_photo.jpg');
      expect(await File(path).readAsBytes(), [7, 7, 7]);
    });

    test('re-writing the same exercise overwrites, not accumulates', () async {
      await service.writeIcon(tempDir, 'ex1', Uint8List.fromList([1]));
      final path = await service.writeIcon(
        tempDir,
        'ex1',
        Uint8List.fromList([2]),
      );

      expect(await File(path).readAsBytes(), [2]);
      expect(tempDir.listSync(), hasLength(1));
    });

    test('creates the target directory if it does not exist yet', () async {
      final nested = Directory('${tempDir.path}/nested');
      expect(await nested.exists(), isFalse);

      await service.writeIcon(nested, 'ex1', Uint8List.fromList([1]));

      expect(await nested.exists(), isTrue);
    });
  });

  group('deleteFile', () {
    test('does nothing for a null path', () async {
      await service.deleteFile(null);
    });

    test('does nothing for an already-missing file', () async {
      await service.deleteFile('${tempDir.path}/does-not-exist.jpg');
    });

    test('deletes an existing file', () async {
      final path = await service.writeIcon(
        tempDir,
        'ex1',
        Uint8List.fromList([1]),
      );
      expect(await File(path).exists(), isTrue);

      await service.deleteFile(path);

      expect(await File(path).exists(), isFalse);
    });
  });
}
