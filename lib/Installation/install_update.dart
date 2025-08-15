import 'dart:io'; // Import to check platform
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void installApk(String filePath) async {
  if (Platform.isAndroid) {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/app-latest.apk';
      final File file = File(filePath);

      if (!file.existsSync()) {
        if (kDebugMode) {
          print("❌ APK file not found at: $filePath");
        }
        return;
      }

      if (kDebugMode) {
        print("✅ APK found at: $filePath");
      }

      // Get the correct content URI using FileProvider
      final contentUri = "content://com.example.ppms.provider/downloaded_apk/app-latest.apk";

      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: contentUri,
        type: 'application/vnd.android.package-archive',
        flags: <int>[
          Flag.FLAG_GRANT_READ_URI_PERMISSION,
          Flag.FLAG_ACTIVITY_NEW_TASK,
        ],
      );

      await intent.launch();
    } catch (e) {
      print("❌ Installation error: $e");
    }
  }
  else if (Platform.isIOS) {
    // iOS-specific behavior or just a log
    if (kDebugMode) {
      print('InstallPlugin is not supported on iOS.');
    }
    // Optionally, handle iOS-specific behavior, such as redirecting to App Store
  }
}
