import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'install_update.dart';

Future<void> downloadApk(BuildContext context, String apkUrl) async {
  Dio dio = Dio();

  // Get the app's download directory
  Directory? appDocDir = await getExternalStorageDirectory();
  String filePath = '${appDocDir?.path}/app-latest.apk';

  // Create a ValueNotifier to track download progress
  ValueNotifier<double> progressNotifier = ValueNotifier(0);

  // Show the dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Downloading...'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Progress indicator
                SizedBox(height: 20),
                // Text to show the percentage
                ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, value, child) {
                    return Text('${(value * 100).toStringAsFixed(0)}%');
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );

  try {
    // Perform the download and track progress
    await dio.download(apkUrl, filePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        // Update progress
        double progress = received / total;
        print((progress * 100).toStringAsFixed(0) + "%");

        // Update the ValueNotifier with the new progress
        progressNotifier.value = progress;
      }
    });

    // Once download is complete, close the dialog and install the APK
    if (context.mounted) {
      Navigator.of(context).pop(); // Close the dialog
      installApk(filePath); // Call the install function
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error while downloading APK: $e');
    }
    // Close the dialog in case of error
    if (context.mounted) {
      Navigator.of(context).pop();
      // Optionally show an error message
      showErrorDialog(context, e.toString());
    }
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text('Not Able to Download'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
