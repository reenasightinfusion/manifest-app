import 'package:flutter/material.dart';
import 'url_strategy_noop.dart'
    if (dart.library.js_util) 'url_strategy_web.dart';
import 'my_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const MyApp());
}
