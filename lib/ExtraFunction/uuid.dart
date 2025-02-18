import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PersistentUUID {
  static const _storage = FlutterSecureStorage();
  static const uuidKey = 'persistent_uuid';

  /// Fetches the UUID, generating and storing it securely if not already present.
  static Future<String> getOrCreateUUID() async {
    // Check if UUID already exists
    String? uuid = await _storage.read(key: uuidKey);

    if (uuid == null) {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        uuid = androidInfo.id;
      } else if (Platform.isIOS) {
        uuid = const Uuid().v4();
      }
      uuid = uuid?.replaceAll('.', '').substring(0, 8);

      // Store the UUID securely
      if (uuid != null) {
        await _storage.write(key: uuidKey, value: uuid);
      }
    }

    return uuid!;
  }
}
