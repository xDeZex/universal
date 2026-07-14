// flutter_driver is a dev_dependency; this debug-only entrypoint is never
// shipped, so it's safe to reference from lib/ here.
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
