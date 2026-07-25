import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/workout_status_menu.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({
  required WorkoutStatus status,
  required ValueChanged<WorkoutStatus> onSelectStatus,
  WorkoutStatus? excludeStatus,
  VoidCallback? onDelete,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: WorkoutStatusMenu(
        status: status,
        onSelectStatus: onSelectStatus,
        excludeStatus: excludeStatus,
        onDelete: onDelete,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'excludeStatus hides the transition already covered by the primary CTA',
    (tester) async {
      await tester.pumpWidget(
        _appUnderTest(
          status: WorkoutStatus.draft,
          onSelectStatus: (_) {},
          excludeStatus: WorkoutStatus.inProgress,
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<Object>));
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Start workout'), findsNothing);
    },
  );

  testWidgets('selecting a transition calls onSelectStatus with it', (
    tester,
  ) async {
    WorkoutStatus? selected;
    await tester.pumpWidget(
      _appUnderTest(
        status: WorkoutStatus.draft,
        onSelectStatus: (status) => selected = status,
        excludeStatus: WorkoutStatus.inProgress,
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(selected, WorkoutStatus.planned);
  });

  testWidgets('onDelete adds a Delete entry that invokes the callback', (
    tester,
  ) async {
    var deleted = false;
    await tester.pumpWidget(
      _appUnderTest(
        status: WorkoutStatus.draft,
        onSelectStatus: (_) {},
        onDelete: () => deleted = true,
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets('omitting onDelete hides the Delete entry', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(status: WorkoutStatus.draft, onSelectStatus: (_) {}),
    );

    await tester.tap(find.byType(PopupMenuButton<Object>));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsNothing);
  });

  testWidgets(
    'renders nothing when the only transition is excluded and there is no delete',
    (tester) async {
      // completed -> {inProgress} is the state machine's only single-
      // transition status (DM 6.4.1): excluding it with no onDelete truly
      // empties the menu.
      await tester.pumpWidget(
        _appUnderTest(
          status: WorkoutStatus.completed,
          onSelectStatus: (_) {},
          excludeStatus: WorkoutStatus.inProgress,
        ),
      );

      expect(find.byType(PopupMenuButton<Object>), findsNothing);
    },
  );
}
