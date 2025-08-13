import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'locale_rebuilder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

/// Корневое приложение с двумя страницами.
/// Проверяем кейс: меняем локаль на странице 2,
/// возвращаемся назад и убеждаемся, что страница 1 уже на новой локали.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LocaleRebuilder(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'LocaleRebuilder MVP',
        routes: {'/': (_) => const PageOne(), '/page2': (_) => const PageTwo()},
        initialRoute: '/',
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('page1.title'.tr())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('page1.body'.tr(), key: const Key('page1_text')),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  key: const Key('btn_en_page1'),
                  onPressed: () => context.setLocale(const Locale('en')),
                  child: const Text('EN'),
                ),
                ElevatedButton(
                  key: const Key('btn_ru_page1'),
                  onPressed: () => context.setLocale(const Locale('ru')),
                  child: const Text('RU'),
                ),
                ElevatedButton(
                  key: const Key('goto_page2'),
                  onPressed: () => Navigator.of(context).pushNamed('/page2'),
                  child: Text('page1.to_page2'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('page2.title'.tr())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('page2.body'.tr(), key: const Key('page2_text')),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  key: const Key('btn_en_page2'),
                  onPressed: () => context.setLocale(const Locale('en')),
                  child: const Text('EN'),
                ),
                ElevatedButton(
                  key: const Key('btn_ru_page2'),
                  onPressed: () => context.setLocale(const Locale('ru')),
                  child: const Text('RU'),
                ),
                ElevatedButton(
                  key: const Key('back_to_page1'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('page2.back'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
