import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSystemIO {
  Future<bool> requestAccess() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    return await Permission.storage.isGranted && await Permission.manageExternalStorage.isGranted;
  }

  Future<void> saveFile(String path, String content) async {
    final file = File(path);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  Future<String> getWidgetAssetDirectoty(String folderName) async {
    final directory = await getDownloadsDirectory();
    debugPrint("${directory!.path}/widget_asset/$folderName");
    //"/storage/emulated/0/Android/data/com.example.widget_ai/files/downloads/widget_asset/demo_app" could not be found
    return "${directory.path}/widget_asset/$folderName";
  }

  Future<String?> readFile(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<Uint8List?> readBytes(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
