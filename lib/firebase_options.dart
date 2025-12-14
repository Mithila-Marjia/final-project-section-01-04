// File generated to support Firebase initialization
// For Android: Uses google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android uses google-services.json
        return const FirebaseOptions(
          apiKey: 'AIzaSyAkSqmOfowPaKP2qwlLF37N-JnrZ8sjtOE',
          appId: '1:469421837688:android:249f6edd02a0fedfca4c8d',
          messagingSenderId: '469421837688',
          projectId: 'ecom-6b907',
          storageBucket: 'ecom-6b907.firebasestorage.app',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
