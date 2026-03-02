import 'package:widget_ai/model/chat_message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;
  ChatLoading(this.messages);
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatLoaded({required this.messages, this.isTyping = false});
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> messages;
  ChatError(this.message, this.messages);
}

/// Emitted after the LLM finalizes code generation and all files are written
/// to the device filesystem.
class ChatCodeSaved extends ChatState {
  final List<ChatMessage> messages;

  /// Absolute file paths of every file written to disk.
  final List<String> savedFilePaths;

  /// The root directory that contains all generated project files.
  final String projectFolderPath;

  ChatCodeSaved({required this.messages, required this.savedFilePaths, required this.projectFolderPath});
}
