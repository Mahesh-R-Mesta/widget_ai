import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_ai/service/file_system.dart';
import 'package:widget_ai/service/locator.dart';

class NativeBridgeService {
  final _picker = ImagePicker();
  final _fileSystem = locator<FileSystemIO>();

  // ── UI / UX ───────────────────────────────────────────────────────────────

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  Future<void> showDialogBox(BuildContext context, String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<bool> confirm(BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
    return result ?? false;
  }

  void haptic(String type) {
    switch (type) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      default:
        HapticFeedback.vibrate();
    }
  }

  // ── Media ─────────────────────────────────────────────────────────────────

  Future<String?> openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  Future<String?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  // ── Clipboard ─────────────────────────────────────────────────────────────

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> readFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  // ── Filesystem ────────────────────────────────────────────────────────────

  Future<void> writeFile(String projectPath, String filename, String content) async {
    final path = '$projectPath/$filename';
    await _fileSystem.saveFile(path, content);
  }

  Future<String?> readFile(String projectPath, String filename) async {
    final path = '$projectPath/$filename';
    return await _fileSystem.readFile(path);
  }

  Future<void> deleteFile(String projectPath, String filename) async {
    final path = '$projectPath/$filename';
    await _fileSystem.deleteFile(path);
  }

  // ── System Intents ────────────────────────────────────────────────────────

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendEmail(String to, String subject, String body) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> share(String text) async {
    await Share.share(text);
  }
}
