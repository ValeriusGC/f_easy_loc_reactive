# LocaleRebuilder MVP

Минимальный тестовый проект, демонстрирующий, как корректно перестраивать экраны
в стеке при смене локали с [easy_localization](https://pub.dev/packages/easy_localization).

Фикс адресует проблему: при смене языка текущий экран обновляется,
а экраны под ним — нет [см.](https://github.com/aissat/easy_localization/issues/370)

## Идея
Создаём виджет-обёртку LocaleRebuilder, который:
- подписывается на context.locale (через InheritedWidget внутри easy_localization);
- только при фактической смене локали помечает всё поддерево как “грязное” 
   (markNeedsBuild), вызывая перестройку всех потомков;
- не вмешивается в обычный цикл build и не создаёт “шторм” перестроек.

