import 'dart:convert';

enum MessageSender { user, bot }

enum MessageType { text, image, document, codeGenerated }

class ChatMessage {
  final String? text;
  final String? rawText; // Full LLM response including code blocks.
  final String? filePath;
  final MessageSender sender;
  final MessageType type;
  final DateTime timestamp;
  final int? fileCount; // Populated for codeGenerated messages.

  ChatMessage({
    this.text,
    this.rawText,
    this.filePath,
    required this.sender,
    required this.type,
    this.fileCount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == MessageSender.user;
  bool get isBot => sender == MessageSender.bot;

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'text': text,
    'rawText': rawText,
    'filePath': filePath,
    'sender': sender.name,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    if (fileCount != null) 'fileCount': fileCount,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String?,
      rawText: json['rawText'] as String?,
      filePath: json['filePath'] as String?,
      sender: MessageSender.values.byName(json['sender'] as String),
      type: MessageType.values.byName(json['type'] as String),
      fileCount: json['fileCount'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String encodeList(List<ChatMessage> messages) => jsonEncode(messages.map((m) => m.toJson()).toList());

  static List<ChatMessage> decodeList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList();
  }
}
