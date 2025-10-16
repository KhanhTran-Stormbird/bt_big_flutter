import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env (dev) or .env.production (release)
  await dotenv.load(fileName: kReleaseMode ? '.env.production' : '.env');

  setUrlStrategy(PathUrlStrategy());
  runApp(const ProviderScope(child: TluApp()));
}
