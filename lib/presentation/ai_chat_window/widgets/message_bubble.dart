import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_ai/model/chat_message.dart';
import 'package:widget_ai/utility/theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  String _cleanContent(String content) {
    // If the reply is wrapped in AIChatMessage{ content: ..., ... }, extract just the content.
    final exp = RegExp(r'AIChatMessage\{\s*content:\s*(.*?)(?:,\s*\w+:|$)', dotAll: true);
    final match = exp.firstMatch(content.trim());
    if (match != null) {
      String cleaned = match.group(1)?.trim() ?? content;
      // If the extracted content ends with a comma (due to more fields following), strip it.
      if (cleaned.endsWith(',')) {
        cleaned = cleaned.substring(0, cleaned.length - 1).trim();
      }
      return cleaned;
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.codeGenerated) {
      return _CodeGeneratedCard(message: message);
    }

    final cleanedText = _cleanContent(message.text ?? '');

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == MessageType.text)
              message.isUser
                  ? Text(cleanedText, style: const TextStyle(color: Colors.white))
                  : MarkdownBody(
                      data: cleanedText,
                      styleSheet: MarkdownStyleSheet(p: const TextStyle(color: Colors.black87)),
                    ),
            if (message.type == MessageType.image && message.filePath != null)
              Image.file(File(message.filePath!), width: 200, fit: BoxFit.cover),
            if (message.type == MessageType.document && message.filePath != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description, color: message.isUser ? Colors.white : Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    message.filePath!.split('/').last,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 10, color: message.isUser ? Colors.white70 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact card shown in place of raw code when the LLM has finished
/// generating all project files.
class _CodeGeneratedCard extends StatelessWidget {
  final ChatMessage message;

  const _CodeGeneratedCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final fileCount = message.fileCount ?? 0;
    final summaryText = message.text;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Widget Generated!',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        if (fileCount > 0)
                          Text(
                            '$fileCount file${fileCount == 1 ? '' : 's'} saved to your device',
                            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              // Optional LLM summary text (stripped of code blocks)
              if (summaryText != null && summaryText.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Divider(color: AppColors.primary.withValues(alpha: 0.2), height: 1),
                SizedBox(height: 10.h),
                Text(
                  summaryText,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
              SizedBox(height: 10.h),
              // File chips row
              if (fileCount > 0)
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: _fileLabels(fileCount)
                      .map(
                        (label) => Chip(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          label: Text(
                            label,
                            style: TextStyle(fontSize: 11.sp, color: AppColors.primary),
                          ),
                          avatar: Icon(Icons.insert_drive_file_rounded, size: 14.sp, color: AppColors.primary),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 8.h),
              Text(
                "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '00')}",
                style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns placeholder file labels based on the saved file count.
  List<String> _fileLabels(int count) {
    const common = ['index.html', 'style.css', 'script.js', 'manifest.json', 'app.js'];
    if (count <= common.length) return common.take(count).toList();
    return List.generate(count, (i) => i < common.length ? common[i] : 'file_${i + 1}');
  }
}
