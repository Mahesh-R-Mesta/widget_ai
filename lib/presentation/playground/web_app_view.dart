import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widget_ai/model/app_project_details.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/presentation/ai_chat_window/chat_window.dart';
import 'package:widget_ai/presentation/ai_chat_window/widgets/js_bridge_shim.dart';
import 'package:widget_ai/service/locator.dart';
import 'package:widget_ai/service/native_bridge_service.dart';
import 'package:widget_ai/utility/theme.dart';

class WebAppView extends StatefulWidget {
  final WidgetModelData project;

  const WebAppView({super.key, required this.project});

  @override
  State<WebAppView> createState() => _WebAppViewState();
}

class _WebAppViewState extends State<WebAppView> {
  late final WebViewController _webController;
  final _nativeBridge = locator<NativeBridgeService>();

  /// Drives the loading indicator overlay.
  final _isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _isLoading.value = false;
            _webController.runJavaScript(JsBridgeShim.shim);
          },
          onWebResourceError: (_) => _isLoading.value = false,
        ),
      )
      ..addJavaScriptChannel(
        'nativeBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleNativeCall(message.message);
        },
      );
    _loadWidget();
  }

  /// Loads the generated widget directly from the filesystem — no HTTP server needed.
  ///
  /// [WebViewController.loadFile] uses the platform's native file-loading API:
  ///   • Android: `WebViewAssetLoader` (relative paths for CSS/JS/images work).
  ///   • iOS: `WKWebView.loadFileURL(_:allowingReadAccessTo:)` (whole folder is accessible).
  Future<void> _loadWidget() async {
    final folderPath = widget.project.location;
    if (folderPath == null) {
      Fluttertoast.showToast(msg: 'Project path not found');
      _isLoading.value = false;
      return;
    }

    final indexFile = File('$folderPath/index.html');
    if (!indexFile.existsSync()) {
      Fluttertoast.showToast(msg: 'index.html not found in project folder');
      _isLoading.value = false;
      return;
    }

    try {
      await _webController.loadFile(indexFile.path);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load widget: $e');
      _isLoading.value = false;
    }
  }

  Future<void> _handleNativeCall(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      final module = data['module'];
      final method = data['method'];
      final args = data['args'];
      final callId = data['id'];

      dynamic result;

      switch (module) {
        case 'ui':
          if (method == 'showToast') {
            _nativeBridge.showToast(args['message']);
          }
          if (mounted && method == 'showDialog') {
            await _nativeBridge.showDialogBox(context, args['title'], args['message']);
          }
          if (mounted && method == 'confirm') {
            result = await _nativeBridge.confirm(context, args['title'], args['message']);
          }
          if (method == 'haptic') {
            _nativeBridge.haptic(args['type']);
          }
          break;
        case 'media':
          if (method == 'openCamera') {
            result = await _nativeBridge.openCamera();
          }
          if (method == 'pickImage') {
            result = await _nativeBridge.pickImage();
          }
          break;
        case 'clipboard':
          if (method == 'copy') {
            await _nativeBridge.copyToClipboard(args['text']);
          }
          if (method == 'read') {
            result = await _nativeBridge.readFromClipboard();
          }
          break;
        case 'file':
          if (widget.project.location != null) {
            if (method == 'write') {
              await _nativeBridge.writeFile(widget.project.location!, args['filename'], args['content']);
            }
            if (method == 'read') {
              result = await _nativeBridge.readFile(widget.project.location!, args['filename']);
            }
            if (method == 'delete') {
              await _nativeBridge.deleteFile(widget.project.location!, args['filename']);
            }
          }
          break;
        case 'intent':
          if (method == 'openUrl') {
            await _nativeBridge.openUrl(args['url']);
          }
          if (method == 'sendEmail') {
            await _nativeBridge.sendEmail(args['to'], args['subject'], args['body']);
          }
          if (method == 'share') {
            await _nativeBridge.share(args['text']);
          }
          break;
      }

      // Send result back to JS
      final callback = 'window.native_callback_$callId(${jsonEncode(result)}, null)';
      await _webController.runJavaScript(callback);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Bridge error: $e');
      debugPrint('Native bridge error: $e');
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatWindow(
          projectDetails: AppProjectDetails(
            appName: widget.project.name,
            description: widget.project.description,
            iconImagePath: widget.project.iconPath,
          ),
          projectId: widget.project.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
              child: const BackButton(color: AppColors.textPrimary),
            ),
          ),
        ),
        title: Text(widget.project.name, style: Theme.of(context).textTheme.titleMedium),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          // ── Open chat to iterate on this project ─────────────────────────
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              tooltip: 'Chat with AI',
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                child: Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20.sp),
              ),
              onPressed: _openChat,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),

          // ── Loading overlay ──────────────────────────────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (_, loading, __) => loading
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading widget…',
                            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
