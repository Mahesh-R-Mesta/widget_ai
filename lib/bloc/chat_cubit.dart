import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:widget_ai/bloc/chat_state.dart';
import 'package:widget_ai/llm/models/antropic_model.dart';
import 'package:widget_ai/llm/models/gemin_model.dart';
import 'package:widget_ai/llm/programing_assistant.dart';
import 'package:widget_ai/model/app_project_details.dart';
import 'package:widget_ai/model/chat_message.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/service/locator.dart';

/// Drives the chat screen.
///
/// Delegates all LLM interactions to [ProgrammingAssistant] and persists the
/// conversation history + project metadata to the Drift [AppDatabase].
class ChatCubit extends Cubit<ChatState> {
  final ProgrammingAssistant _assistant;
  final AppDatabase _db;
  final List<ChatMessage> _messages = [];

  /// The Drift row id for this project. Set after the first [initialise] call.
  int? _projectId;

  /// Exposed so the UI layer can fetch the full project row from the DB.
  int? get projectId => _projectId;

  ChatCubit({required ProgrammingAssistant assistant})
    : _assistant = assistant,
      _db = locator<AppDatabase>(),
      super(ChatInitial());

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Called when starting a **new** project from [CreateWidgetPage].
  ///
  /// Inserts a project row into the DB, initialises the LLM session, and emits
  /// the opening Phase 1 clarification questions from the assistant.
  Future<void> initialise(AppProjectDetails projectDetails) async {
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true, typingMessage: 'Setting up your project...'));
    try {
      // 1. Persist the project immediately so it shows on the home screen.
      _projectId = await _db.insertProject(
        WidgetModelCompanion.insert(
          name: projectDetails.appName,
          description: projectDetails.description,
          iconPath: projectDetails.iconImagePath != null ? Value(projectDetails.iconImagePath) : const Value.absent(),
          llmModel: Value(projectDetails.llmModel),
        ),
      );

      // 2. Boot the LLM session.
      final model = projectDetails.llmModel == 'anthropic' ? locator<AnthropicModel>() : locator<GeminiModel>();
      await _assistant.initialise(projectDetails, model);

      // 3. Kick off Phase 1.
      emit(
        ChatLoaded(messages: List.from(_messages), isTyping: true, typingMessage: 'Curating project requirements...'),
      );
      final opening = await _assistant.sendMessage('Hello! I have a new project for you. Please start Phase 1.');
      final botMessage = ChatMessage(
        text: opening.text,
        rawText: opening.rawReply,
        sender: MessageSender.bot,
        type: MessageType.text,
      );
      _messages.add(botMessage);
      await _persistHistory();

      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      emit(ChatError(e.toString(), List.from(_messages)));
      rethrow;
    }
  }

  /// Called when reopening an **existing** project from [WebAppView].
  ///
  /// Loads the persisted chat history from the DB and restores it in the UI
  /// without sending any new message to the LLM.
  Future<void> restoreSession(int projectId) async {
    _projectId = projectId;
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true, typingMessage: 'Restoring project history...'));
    try {
      final project = await _db.getProjectById(projectId);
      final List<ChatMessage> history;
      if (project != null && project.chatHistory != null) {
        history = ChatMessage.decodeList(project.chatHistory!);
        _messages.addAll(history);
      } else {
        history = [];
      }

      // Re-initialise the assistant session with the stored model.
      final modelName = project?.llmModel ?? 'gemini';
      final model = modelName == 'anthropic' ? locator<AnthropicModel>() : locator<GeminiModel>();
      final details = AppProjectDetails(
        appName: project?.name ?? '',
        description: project?.description ?? '',
        iconImagePath: project?.iconPath,
        llmModel: modelName,
      );
      await _assistant.initialise(details, model);
      await _assistant.restoreHistory(history);

      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      emit(ChatError(e.toString(), List.from(_messages)));
    }
  }

  // ── Message handling ───────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final userMessage = ChatMessage(text: text, sender: MessageSender.user, type: MessageType.text);
    _messages.add(userMessage);
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true, typingMessage: 'Architecting solution...'));

    try {
      final reply = await _assistant.sendMessage(text);

      // If the assistant finalized code, emit a dedicated summary bubble.
      final botMessageType = reply.isCodeFinalized ? MessageType.codeGenerated : MessageType.text;
      final botMessage = ChatMessage(
        text: reply.text.isNotEmpty ? reply.text : null,
        rawText: reply.rawReply,
        sender: MessageSender.bot,
        type: botMessageType,
        fileCount: reply.isCodeFinalized ? reply.savedFiles.length : null,
      );
      _messages.add(botMessage);
      await _persistHistory();

      if (reply.isCodeFinalized) {
        // Update the project folder location in the DB.
        if (_projectId != null && _assistant.projectFolderPath != null) {
          await _db.updateProjectLocation(_projectId!, _assistant.projectFolderPath!);
        }
        emit(
          ChatCodeSaved(
            messages: List.from(_messages),
            savedFilePaths: reply.savedFiles.map((f) => f.path).toList(),
            projectFolderPath: _assistant.projectFolderPath ?? '',
          ),
        );
      } else {
        emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      emit(ChatError(e.toString(), List.from(_messages)));
    }
  }

  // ── File attachment handling ───────────────────────────────────────────────

  Future<void> pickFile(MessageType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type == MessageType.image ? FileType.image : FileType.any,
      withData: true, // Request bytes for multimodal input
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final path = file.path!;
      final bytes = file.bytes;
      final userMessage = ChatMessage(filePath: path, sender: MessageSender.user, type: type);
      _messages.add(userMessage);
      emit(ChatLoaded(messages: List.from(_messages), isTyping: true, typingMessage: 'Analyzing visual context...'));

      final typeName = type == MessageType.image ? 'image' : 'document';
      final mimeType = type == MessageType.image ? 'image/${path.split('.').last}' : null;

      final prompt = type == MessageType.image
          ? 'I am providing this image/mockup as visual context for the app building process: ${file.name}. Please analyze it and use it as a reference.'
          : 'I am attaching a $typeName reference: ${file.name}';

      final reply = await _assistant.sendMessage(prompt, fileBytes: bytes, mimeType: mimeType);
      final botMessage = ChatMessage(
        text: reply.text,
        rawText: reply.rawReply,
        sender: MessageSender.bot,
        type: MessageType.text,
      );
      _messages.add(botMessage);
      await _persistHistory();
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _persistHistory() async {
    if (_projectId == null || _messages.isEmpty) return;
    try {
      await _db.updateChatHistory(_projectId!, ChatMessage.encodeList(_messages));
    } catch (_) {
      // History persistence is non-critical; swallow silently.
    }
  }
}
