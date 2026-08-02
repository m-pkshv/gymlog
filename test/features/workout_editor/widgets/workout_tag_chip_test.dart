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

    test('the standalone "Legs" and "Crossfit" tags translate directly', () {
      final legs = _tag('legs', 'Legs');
      final crossfit = _tag('crossfit', 'Crossfit');

      expect(workoutTagLabel(AppLocalizationsEn(), legs), 'Legs');
      expect(workoutTagLabel(AppLocalizationsRu(), legs), 'Ноги');
      expect(workoutTagLabel(AppLocalizationsEn(), crossfit), 'Crossfit');
      expect(workoutTagLabel(AppLocalizationsRu(), crossfit), 'Кроссфит');
    });
  });

  group(
    'sortedWorkoutTags (Stage 12, owner-confirmed 2026-08-02: alphabetical '
    'by displayed label, built-in and user-created tags mixed together, '
    'computed on screen rather than stored/queried by position)',
    () {
      test(
        'sorts by translated label, not by id/insertion order, and ignores '
        'case',
        () {
          final tags = [
            _tag('chest', 'Chest'), // -> "Chest"
            _tag('user-tag', 'middle'), // shown as-is, lowercase on purpose
            _tag('back', 'Back'), // -> "Back"
          ];

          final sorted = sortedWorkoutTags(tags, AppLocalizationsEn());

          expect(
            sorted.map((t) => workoutTagLabel(AppLocalizationsEn(), t)),
            ['Back', 'Chest', 'middle'],
          );
        },
      );

      test('does not mutate the list passed in', () {
        final original = [_tag('chest', 'Chest'), _tag('back', 'Back')];
        final originalOrder = List.of(original);

        sortedWorkoutTags(original, AppLocalizationsEn());

        expect(original.map((t) => t.id), originalOrder.map((t) => t.id));
      });
    },
  );
}
