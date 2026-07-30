import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/user_profile_repository_impl.dart';
import 'package:gymlog/features/profile/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ProfileScreen(),
    ),
  );
}

/// Same rationale as the other flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('loads the existing name fields (DM 6.15)', (tester) async {
    final repository = UserProfileRepositoryImpl(db);
    await repository.ensureInitialized();
    await repository.setNickname('Max');
    await repository.setFirstName('Maksim');
    await repository.setLastName('Pekshev');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Maksim'), findsOneWidget);
    expect(find.text('Pekshev'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'editing the nickname field and losing focus persists it',
    (tester) async {
      await UserProfileRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nickname'),
        'Max',
      );
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final row = await (db.select(
        db.userProfileTable,
      )..where((t) => t.id.equals('singleton'))).getSingle();
      expect(row.nickname, 'Max');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'shows a placeholder icon when no avatar is set',
    (tester) async {
      await UserProfileRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'tapping the avatar opens a sheet with only "Choose photo" when none is '
    'set',
    (tester) async {
      await UserProfileRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      expect(find.text('Choose photo'), findsOneWidget);
      expect(find.text('Remove photo'), findsNothing);

      // Dismiss the sheet before unmounting.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'tapping "Remove photo" clears the stored avatar path',
    (tester) async {
      // No real file/decode here on purpose -- `UserProfileService.
      // removeAvatar`'s full file-deletion behavior (including a real
      // image) is already covered by `user_profile_service_test.dart`
      // without any widget/rendering involved; this test only checks the
      // screen's orchestration (menu item shown, tap wired to the service,
      // UI reflects the cleared path). A nonexistent path is enough to
      // reach the "Remove photo" branch -- `_ProfileAvatar`'s
      // `onBackgroundImageError` handles the resulting missing-file decode
      // failure gracefully instead of surfacing it.
      // `Platform.pathSeparator`, not a hardcoded '/': on Windows, a path
      // mixing '\' (from `Directory.systemTemp.path`) and '/' made
      // `File.exists()` hang indefinitely in this environment -- a real,
      // reproducible platform quirk with mixed separators, not a flutter_test
      // artifact.
      final nonexistentPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'gymlog_profile_test_missing_avatar.jpg';
      final repository = UserProfileRepositoryImpl(db);
      await repository.ensureInitialized();
      await repository.setAvatarPath(nonexistentPath);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_outline), findsNothing);

      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();
      expect(find.text('Remove photo'), findsOneWidget);
      await tester.tap(find.text('Remove photo'));
      // `removeAvatar` goes through a real `dart:io File.exists()` check
      // before the DB write -- real async I/O like this doesn't reliably
      // resolve inside `testWidgets`'s FakeAsync zone on its own;
      // `runAsync` briefly leaves that zone so it can actually complete
      // before `pumpAndSettle` picks the resulting rebuild back up.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      final row = await (db.select(
        db.userProfileTable,
      )..where((t) => t.id.equals('singleton'))).getSingle();
      expect(row.avatarPath, isNull);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );
}
