// PLACEHOLDER — replace this file by running, in the project folder:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command links the app to your Firebase project and overwrites this
// file with the real keys for every platform. See README.md → "Firebase setup".

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase is not configured yet. Run `flutterfire configure` '
    '(see README.md → Firebase setup).',
  );
}
