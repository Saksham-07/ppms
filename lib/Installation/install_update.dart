import 'dart:io'; // Import to check platform
import 'package:flutter/foundation.dart';
import 'package:install_plugin/install_plugin.dart';

void installApk(String filePath) {
  if (Platform.isAndroid) {
    // Only run this on Android
    InstallPlugin.installApk(filePath, appId: 'com.example.ppms')
        .then((result) {
      if (kDebugMode) {
        print('Success: $result');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  } else if (Platform.isIOS) {
    // iOS-specific behavior or just a log
    if (kDebugMode) {
      print('InstallPlugin is not supported on iOS.');
    }
    // Optionally, handle iOS-specific behavior, such as redirecting to App Store
  }
}
