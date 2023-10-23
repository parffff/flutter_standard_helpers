import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<String> getString(String key) async {
    String? value = await storage.read(key: key);
    return value ?? '';
  }

  Future<void> setString(String key, String value) async {
    storage.write(key: key, value: value);
  }
}
