import 'package:flutter/widgets.dart';

import 'locale_controller.dart';

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope(
      {super.key, required LocaleController controller, required super.child})
      : super(notifier: controller);

  static LocaleController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LocaleScope>()!
      .notifier!;
}
