import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Оборачивает поддерево и принудительно помечает все элементы как dirty
/// (через markNeedsBuild) при смене локали, чтобы экраны в стеке
/// тоже обновлялись. Костыль для бага easy_localization.
/// См. https://github.com/aissat/easy_localization/issues/370
class LocaleRebuilder extends StatefulWidget {
  const LocaleRebuilder({super.key, required this.child});

  /// Поддерево, которое будет перестроено при смене локали.
  final Widget child;

  @override
  State<LocaleRebuilder> createState() => _LocaleRebuilderState();
}

class _LocaleRebuilderState extends State<LocaleRebuilder> {
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ВАЖНО: обращение к context.locale создаёт зависимость от InheritedWidget
    // внутри easy_localization → этот метод будет вызван при смене локали.
    final currentLocale = context.locale;

    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;

      // Откладываем пометку на следующий кадр, чтобы не вмешиваться
      // в текущий цикл билда.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rebuildAllChildren(context);
      });
    }
  }

  void _rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el
        ..markNeedsBuild()
        ..visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
