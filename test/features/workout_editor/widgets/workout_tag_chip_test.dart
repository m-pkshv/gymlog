import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/models/workout_tag.dart';
import 'package:gymlog/features/workout_editor/widgets/workout_tag_chip.dart';
import 'package:gymlog/l10n/app_localizations_en.dart';
import 'package:gymlog/l10n/app_localizations_ru.dart';

final _now = DateTime.utc(2026, 7, 23);

WorkoutTag _tag(String id, String name) {
  return WorkoutTag(
    id: id,
    name: name,
    colorHex: '#4C7BD9',
    isHidden: false,
    createdAt: _now,
    updatedAt: _now,
    isDeleted: false,
  );
}

void main() {
  group('workoutTagLabel (Stage 10, owner-confirmed)', () {
    test(
      'a built-in muscle-group tag translates with the app language',
      () {
        final tag = _tag('chest', 'Chest');

        expect(workoutTagLabel(AppLocalizationsEn(), tag), 'Chest');
        expect(workoutTagLabel(AppLocalizationsRu(), tag), 'Грудь');
      },
    );

    test(
      'a user-created tag always shows its stored name, regardless of '
      'app language (owner-confirmed: no localization for custom tags)',
      () {
        final tag = _tag('user-tag-1', 'Leg day');

        expect(workoutTagLabel(AppLocalizationsEn(), tag), 'Leg day');
        expect(workoutTagLabel(AppLocalizationsRu(), tag), 'Leg day');
      },
    );
  });
}
