import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory загрузчик переводов для easy_localization.
/// По умолчанию содержит минимальный набор строк EN/RU.
/// Можно передать свои переводы через [translations].
class TestInMemoryAssetLoader extends AssetLoader {
  const TestInMemoryAssetLoader({
    this.translations = const {
      'en': {
        'page1.title': 'Page One',
        'page1.body': 'This is page one',
        'page1.to_page2': 'Go to page two',
        'page2.title': 'Page Two',
        'page2.body': 'This is page two',
        'page2.back': 'Back to page one',
      },
      'ru': {
        'page1.title': 'Первая страница',
        'page1.body': 'Это первая страница',
        'page1.to_page2': 'Перейти на вторую',
        'page2.title': 'Вторая страница',
        'page2.body': 'Это вторая страница',
        'page2.back': 'Назад на первую',
      },
    },
  });

  /// Ключ: код языка (en/ru и т.п.).
  /// Значение: мапа ключ→строка для этого языка.
  final Map<String, Map<String, String>> translations;

  @override
  Future<Map<String, dynamic>> load(String _, Locale locale) async {
    final map = translations[locale.languageCode] ?? const <String, String>{};
    // easy_localization ожидает Map<String, dynamic>
    return Map<String, dynamic>.from(map);
  }
}

/// Явно ждём, пока [finder] начнёт что-то находить, прокручивая кадры по одному.
/// Полезно для асинхронной локализации и любых ленивых обновлений.
///
/// [maxFrames] — верхняя граница числа кадров (по умолчанию ~1 сек при 60 fps).
/// [step] — длительность одного кадра.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 60,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxFrames; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
  throw TestFailure('Widget not found within $maxFrames frames: $finder');
}
