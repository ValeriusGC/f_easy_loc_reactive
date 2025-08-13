// test/locale_rebuilder_test.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:f_easy_loc_reactive/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

// /// In-memory переводы — никаких файлов и гонок загрузки.
// class _TestLoader extends AssetLoader {
//   const _TestLoader();
//
//   static const Map<String, Map<String, String>> _t = {
//     'en': {
//       'page1.title': 'Page One',
//       'page1.body': 'This is page one',
//       'page1.to_page2': 'Go to page two',
//       'page2.title': 'Page Two',
//       'page2.body': 'This is page two',
//       'page2.back': 'Back to page one',
//     },
//     'ru': {
//       'page1.title': 'Первая страница',
//       'page1.body': 'Это первая страница',
//       'page1.to_page2': 'Перейти на вторую',
//       'page2.title': 'Вторая страница',
//       'page2.body': 'Это вторая страница',
//       'page2.back': 'Назад на первую',
//     },
//   };
//
//   @override
//   Future<Map<String, dynamic>> load(String path, Locale locale) async {
//     final map = _t[locale.languageCode] ?? const {};
//     return map.map((k, v) => MapEntry(k, v));
//   }
// }
//
// /// Явно ждём, пока finder что-то найдёт (чтобы не полагаться на pumpAndSettle).
// Future<void> pumpUntilFound(
//     WidgetTester tester,
//     Finder finder, {
//       int maxFrames = 60, // ~1 сек при 60fps
//     }) async {
//   for (var i = 0; i < maxFrames; i++) {
//     if (finder.evaluate().isNotEmpty) return;
//     await tester.pump(const Duration(milliseconds: 16));
//   }
//   // последний шанс показать, что было на экране
//   throw TestFailure('Widget not found within $maxFrames frames: $finder');
// }

Future<void> pumpMvpApp(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      key: UniqueKey(), // новый инстанс на каждый тест
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'ignored',                 // не используется
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,               // никаких персистов между тестами
      assetLoader: const TestInMemoryAssetLoader(),// мгновенные переводы
      child: const MyApp(),
    ),
  );

  // Ждём, пока появится текст страницы 1 (EN)
  await pumpUntilFound(tester, find.text('This is page one'));
}

void main() {
  testWidgets(
    'Page below updates when locale is changed on top (RU)',
        (tester) async {
      await pumpMvpApp(tester);

      expect(find.text('This is page one'), findsOneWidget);

      await tester.tap(find.byKey(const Key('goto_page2')));
      await tester.pumpAndSettle();
      expect(find.text('This is page two'), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_ru_page2')));
      await tester.pumpAndSettle();
      expect(find.text('Это вторая страница'), findsOneWidget);

      await tester.tap(find.byKey(const Key('back_to_page1')));
      await tester.pumpAndSettle();
      expect(find.text('Это первая страница'), findsOneWidget);

      // Чисто размонтируем
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'Switching back to EN also updates the page below in stack',
        (tester) async {
      await pumpMvpApp(tester);

      expect(find.text('This is page one'), findsOneWidget);

      await tester.tap(find.byKey(const Key('goto_page2')));
      await tester.pumpAndSettle();
      expect(find.text('This is page two'), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_ru_page2')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_en_page2')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('back_to_page1')));
      await tester.pumpAndSettle();

      expect(find.text('This is page one'), findsOneWidget);
      expect(find.text('Это первая страница'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
