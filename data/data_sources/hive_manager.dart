import 'package:hive/hive.dart';
import 'package:standard_test/core/data/DTO/hive_DTO_base.dart';
import 'dart:convert';
import 'secure_storage_manager.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class HiveManager {
  static Future<List<int>> _getCryptoKeyOnWrite(String boxName) async {
    final SecureStorage storage = SecureStorage();
    String keyStr = await storage.getString('${boxName}_key');
    final List<int> keyBytes;

    if (keyStr.isEmpty) {
      keyBytes = Hive.generateSecureKey();
      keyStr = base64UrlEncode(keyBytes);
      await storage.setString('${boxName}_key', keyStr);
    } else {
      keyBytes = base64Url.decode(keyStr);
    }
    return keyBytes;
  }

  static Future<List<int>?> _getEncryptionKey(String boxName) async {
    final SecureStorage storage = SecureStorage();
    String keyStr = await storage.getString('${boxName}_key');
    List<int>? keyBytes;
    if (keyStr.isNotEmpty) {
      keyBytes = base64Url.decode(keyStr);
    }

    return keyBytes;
  }

  static Future<void> write(String boxName, String key, Object value) async {
    Box box = await Hive.openBox(boxName);
    box.put(key, value);
    box.close();
  }

  static Future<void> writeEncrypted(
      String boxName, String key, Object value) async {
    List<int> encryptionKeyUint8List = await _getCryptoKeyOnWrite(boxName);
    final Box encryptedBox = await Hive.openBox(boxName,
        encryptionCipher: HiveAesCipher(encryptionKeyUint8List));
    encryptedBox.put(key, value);
    encryptedBox.close();
  }

  static Future<Object?> read(String boxName, String key) async {
    Box box = await Hive.openBox(boxName);
    Object? value = box.get(key);
    box.close();
    return value;
  }

  static Future<Object?> readEncrypted(String boxName, String key) async {
    List<int>? encryptionKeyUint8List = await _getEncryptionKey(boxName);
    HiveDTO? value;

    if (encryptionKeyUint8List != null) {
      final Box encryptedBox = await Hive.openBox(boxName,
          encryptionCipher: HiveAesCipher(encryptionKeyUint8List));
      value = encryptedBox.get(key);
      encryptedBox.close();
    }

    return value?.data;
  }

  static Future<void> clearExpired() async {
    final List<String> boxNames = await Hive.getNamesOfBoxes();
    for (String name in boxNames) {
      final List<int>? decryptKey = await _getEncryptionKey(name);
      HiveCipher? cipher;
      if (decryptKey != null) {
        cipher = HiveAesCipher(decryptKey);
      }
      final Box box = await Hive.openBox(name, encryptionCipher: cipher);
      for (String key in box.keys) {
        dynamic value = box.get(key);
        if (value is HiveDTO && value.lifeTime != -1) {
          bool isExpired = value.createdIn
              .add(Duration(seconds: value.lifeTime))
              .isBefore(DateTime.now());
          if (isExpired) box.delete(key);
        }
      }
      box.close();
    }
  }
}

extension on HiveInterface {
  /// Get a name list of existing boxes
  Future<List<String>> getNamesOfBoxes() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDir.listSync();
    List<String> list = [];

    for (FileSystemEntity file in files) {
      if (file.statSync().type == FileSystemEntityType.file &&
          p.extension(file.path).toLowerCase() == '.hive') {
        list.add(p.basenameWithoutExtension(file.path));
      }
    }

    return list;
  }
}
