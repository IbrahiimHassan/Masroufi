import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow portrait AND landscape on every device.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  // sqflite works out of the box on Android / iOS / macOS.
  // Windows and Linux desktop need the FFI database factory.
  // (Flutter web is NOT supported by sqflite.)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Open (and create / migrate / seed) the database before the first frame.
  final appDatabase = AppDatabase.instance;
  await appDatabase.database;

  final preferences = await SharedPreferences.getInstance();

  runApp(MasroufiApp(appDatabase: appDatabase, preferences: preferences));
}
