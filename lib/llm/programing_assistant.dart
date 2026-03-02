import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:langchain_core/chat_models.dart' as lc;
import 'package:langchain_core/prompts.dart' as lc;
import 'package:langchain_core/tools.dart' as lc;
import 'package:widget_ai/llm/base_model.dart';
import 'package:widget_ai/model/app_project_details.dart';
import 'package:widget_ai/service/file_system.dart';
import 'package:widget_ai/service/locator.dart';
import 'package:widget_ai/service/shared_preference.dart';
import 'package:widget_ai/service/web_search_service.dart';
import 'package:widget_ai/model/chat_message.dart';
import 'dart:convert';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// The SharedPreferences key under which the resolved project folder path is
/// stored so that other parts of the app (e.g. the WebView) can locate files.
const String _kProjectFolderKey = 'project_folder_path';

/// Sentinel phrase the LLM is instructed to include once it has finished
/// generating all code, so we know to parse + persist the files.
const String _kCodeFinalizedMarker = '[[CODE_FINALIZED]]';

// ---------------------------------------------------------------------------
// ProgrammingAssistant
// ---------------------------------------------------------------------------

/// Orchestrates a multi-turn conversation with the LLM that follows the
/// 4-phase WidgetArchitect workflow described in the system prompt.
///
/// Responsibilities:
///  1. Build a [ConversationChain] with [ConversationBufferMemory] so the LLM
///     remembers the entire session.
///  2. Inject the system prompt (from the .txt asset) + the user's project
///     details as the initial context.
///  3. Detect when the LLM has finished generating code, extract individual
///     files from the response, and persist them to the device filesystem.
///  4. Record the project folder path in [LocalStorage] for later retrieval.
class ProgrammingAssistant {
  ProgrammingAssistant({required FileSystemIO fileSystemIO, required LocalStorage localStorage})
    : _fileSystemIO = fileSystemIO,
      _localStorage = localStorage;

  // ── Dependencies ──────────────────────────────────────────────────────────

  late BaseLLMModel _llmModel;
  final FileSystemIO _fileSystemIO;
  final LocalStorage _localStorage;

  // ── Internal state ────────────────────────────────────────────────────────

  final List<lc.ChatMessage> _history = [];

  /// Whether the conversation has been initialised with the system prompt and
  /// project context.
  bool get isInitialised => _history.isNotEmpty;

  /// The resolved filesystem folder for this project's generated files.
  String? get projectFolderPath => _projectFolderPath;
  String? _projectFolderPath;

  /// Tools available to the assistant.
  late final List<lc.ToolSpec> _tools;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Must be called once before any chat interaction.
  ///
  /// [projectDetails] – The app name + description the user filled in on
  ///   [CreateWidgetPage].
  /// [llmModel] – The model to use for this session.
  Future<void> initialise(AppProjectDetails projectDetails, BaseLLMModel llmModel) async {
    _llmModel = llmModel;

    _tools = [
      const lc.ToolSpec(
        name: 'web_search',
        description: 'Performs a web search to find latest documentation, trends, and technical information.',
        inputJsonSchema: {
          'type': 'object',
          'properties': {
            'query': {'type': 'string', 'description': 'The search query'},
          },
          'required': ['query'],
        },
      ),
    ];

    // Capture real device viewport dimensions before any async work.
    final flutterView = PlatformDispatcher.instance.views.first;
    final physicalSize = flutterView.physicalSize;
    final dpr = flutterView.devicePixelRatio;
    final logicalWidth = (physicalSize.width / dpr).round();
    final logicalHeight = (physicalSize.height / dpr).round();
    // 1. Read the system prompt from the bundled asset.
    try {
      final systemPromptText = await _loadSystemPrompt();

      // 2. Build the full initial prompt: system role + project context + viewport.
      final fullSystemPrompt = _buildFullSystemPrompt(
        systemPromptText,
        projectDetails,
        logicalWidth: logicalWidth,
        logicalHeight: logicalHeight,
        devicePixelRatio: dpr,
      );

      // 3. Initialize history with the system prompt.
      _history.clear();
      _history.add(lc.SystemChatMessage(content: fullSystemPrompt));

      // 4. Resolve and cache the project folder path.
      _projectFolderPath = await _fileSystemIO.getWidgetAssetDirectoty(_sanitiseFolderName(projectDetails.appName));
      await _localStorage.setString(_kProjectFolderKey, _projectFolderPath!);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load system prompt $e');
    }
  }

  /// Sends [userMessage] to the LLM and returns its reply.
  ///
  /// If the reply contains [_kCodeFinalizedMarker], the code blocks are
  /// automatically extracted and persisted to [_projectFolderPath].
  ///
  /// Throws a [StateError] if [initialise] has not been called yet.
  Future<AssistantReply> sendMessage(String userMessage, {List<int>? fileBytes, String? mimeType}) async {
    if (_history.isEmpty) {
      throw StateError('ProgrammingAssistant.initialise() must be called before sendMessage().');
    }

    // 1. Add human message to history
    if (fileBytes != null && fileBytes.isNotEmpty) {
      _history.add(
        lc.HumanChatMessage(
          content: lc.ChatMessageContent.multiModal([
            lc.ChatMessageContent.text(userMessage),
            lc.ChatMessageContent.image(data: base64Encode(fileBytes), mimeType: mimeType ?? 'image/jpeg'),
          ]),
        ),
      );
    } else {
      _history.add(lc.HumanChatMessage(content: lc.ChatMessageContent.text(userMessage)));
    }

    lc.ChatResult result;
    int maxTurns = 5;
    int currentTurn = 0;

    while (currentTurn < maxTurns) {
      currentTurn++;

      // 2. Invoke model with tool calling enabled if it's Gemini
      if (_llmModel.model is ChatGoogleGenerativeAI) {
        result = await (_llmModel.model as ChatGoogleGenerativeAI).invoke(
          lc.PromptValue.chat(_history),
          options: ChatGoogleGenerativeAIOptions(tools: _tools),
        );
      } else {
        result = await _llmModel.model.invoke(lc.PromptValue.chat(_history));
      }

      final aiMsg = result.output;
      _history.add(aiMsg);

      if (aiMsg.toolCalls.isNotEmpty) {
        // 3. Handle tool calls
        for (final toolCall in aiMsg.toolCalls) {
          if (toolCall.name == 'web_search') {
            final args = toolCall.arguments;
            final query = args['query'] as String? ?? '';
            final searchResult = await locator<WebSearchService>().search(query);
            _history.add(lc.ToolChatMessage(toolCallId: toolCall.id, content: searchResult));
          } else {
            _history.add(lc.ToolChatMessage(toolCallId: toolCall.id, content: 'Unknown tool: ${toolCall.name}'));
          }
        }
        // Continue loop to send tool results back to LLM
        continue;
      } else {
        // No more tool calls, exit loop
        break;
      }
    }

    var rawReply = _history.last.contentAsString;
    Fluttertoast.showToast(msg: rawReply);

    // 4. Extract content if wrapped in pseudo-serialization (old legacy fix, keeping for safety)
    final exp = RegExp(r'AIChatMessage\{\s*content:\s*(.*?)(?:,\s*\w+:|$)', dotAll: true);
    final match = exp.firstMatch(rawReply.trim());
    if (match != null) {
      rawReply = match.group(1)?.trim() ?? rawReply;
      if (rawReply.endsWith(',')) {
        rawReply = rawReply.substring(0, rawReply.length - 1).trim();
      }
    }

    // Detect whether the LLM has produced the final code payload.
    final isCodeFinalized = rawReply.contains(_kCodeFinalizedMarker);
    debugPrint(rawReply);

    List<GeneratedFile> savedFiles = [];

    if (isCodeFinalized) {
      savedFiles = await _extractAndSaveFiles(rawReply);
    }

    // Return a clean reply (strip the sentinel marker and raw code fences from display text).
    String displayText = rawReply.replaceAll(_kCodeFinalizedMarker, '').trim();
    if (isCodeFinalized) {
      displayText = displayText.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '').trim();
    }
    return AssistantReply(
      text: displayText,
      rawReply: rawReply,
      isCodeFinalized: isCodeFinalized,
      savedFiles: savedFiles,
    );
  }

  /// Rebuilds the internal [_history] from a list of persisted [ChatMessage]s.
  ///
  /// This is called when reopening a project to ensure the LLM has access to
  /// the full conversation context, including raw code and attachments.
  Future<void> restoreHistory(List<ChatMessage> messages) async {
    _history.clear();

    // 1. Re-add the system prompt as the first message.
    // We assume the assistant was already initialised or we'll load it here.
    if (!isInitialised) {
      // If not initialised, we might need a dummy project details or similar,
      // but usually initialise is called before restoreSession in ChatCubit.
      // So we just clear and let the restored messages fill it.
    }

    for (final m in messages) {
      if (m.isUser) {
        if (m.filePath != null && (m.type == MessageType.image)) {
          final bytes = await _fileSystemIO.readBytes(m.filePath!);
          if (bytes != null) {
            final mimeType = 'image/${m.filePath!.split('.').last}';
            _history.add(
              lc.HumanChatMessage(
                content: lc.ChatMessageContent.multiModal([
                  lc.ChatMessageContent.text(m.text ?? ''),
                  lc.ChatMessageContent.image(data: base64Encode(bytes), mimeType: mimeType),
                ]),
              ),
            );
            continue;
          }
        }
        _history.add(lc.HumanChatMessage(content: lc.ChatMessageContent.text(m.text ?? '')));
      } else {
        // Use rawText for bot messages to preserve code and markers.
        _history.add(lc.AIChatMessage(content: m.rawText ?? m.text ?? ''));
      }
    }
  }

  /// Returns the previously-persisted project folder path from storage.
  /// Returns `null` if no project has been set up yet.
  String? getStoredProjectFolderPath() {
    return _localStorage.getString(_kProjectFolderKey);
  }

  /// Resets the assistant so it can be re-initialised for a new project.
  void reset() {
    _history.clear();
    _projectFolderPath = null;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Loads the system prompt text from the bundled Flutter asset.
  Future<String> _loadSystemPrompt() async {
    try {
      return await rootBundle.loadString('lib/service/system_prompt.txt');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load system prompt $e');
      // Fallback if the file is not declared as an asset – read from disk at
      // development time via the services layer.
      return _kFallbackSystemPrompt;
    }
  }

  /// Combines the base system prompt with the user's project context and device viewport.
  String _buildFullSystemPrompt(
    String systemPrompt,
    AppProjectDetails details, {
    required int logicalWidth,
    required int logicalHeight,
    required double devicePixelRatio,
  }) {
    return '''
$systemPrompt

${details.toContextString()}

=== Target Device Viewport ===
The generated widget will run inside a Flutter WebView on a real mobile device.
Design ALL layouts, fonts, and interactions specifically for this screen:
- Logical resolution : ${logicalWidth}px × ${logicalHeight}px  (CSS pixels)
- Device pixel ratio : ${devicePixelRatio.toStringAsFixed(2)}x
- Viewport meta tag  : <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

RULES:
1. Always include the viewport meta tag above in <head>.
2. Use CSS logical pixels (not physical pixels) for sizing.
3. Use responsive units (%, vw, vh, rem) — never hard-code pixel dimensions that assume a desktop browser.
4. Ensure touch targets are at least 44×44 CSS pixels.
5. Do NOT show horizontal scrollbars; the layout must fit ${logicalWidth}px wide.
==============================

IMPORTANT — Code Finalization Protocol:
Each generated file MUST be wrapped in a markdown code block that starts with
a comment containing the filename, for example:
```html
/* filename: index.html */
... file content ...
```

TOOL USAGE:
You have access to a `web_search` tool. Use it to:
1. Find the latest versions of libraries (Tailwind, Lucide, etc.).
2. Research specific UI patterns or technical solutions.
3. Verify if a font or icon is available in standard CDNs.
Before starting Phase 3, if you are unsure about any modern technical detail, USE THE SEARCH TOOL.

4. IMPORTANT — Every time you generate or update code blocks (in Phase 3 or Phase 4), you MUST append the exact string [[CODE_FINALIZED]] as the last characters of your message. This triggers the storage and result window.
''';
  }

  /// Extracts named file blocks from the LLM reply and writes them to disk.
  ///
  /// Expected format (set by the system prompt):
  /// ```<lang>
  /// /* filename: index.html */
  /// ... content ...
  /// ```
  Future<List<GeneratedFile>> _extractAndSaveFiles(String rawReply) async {
    final files = <GeneratedFile>[];
    final folderPath = _projectFolderPath;

    if (folderPath == null) return files;

    // Request storage permission before any write.
    await _fileSystemIO.requestAccess();

    // Regex: captures the filename comment and the body inside each code fence.
    final blockPattern = RegExp(r'```[a-zA-Z]*\s*/\*\s*filename:\s*([^\*]+)\s*\*/\s*([\s\S]*?)```', multiLine: true);

    for (final match in blockPattern.allMatches(rawReply)) {
      final filename = match.group(1)?.trim();
      final content = match.group(2)?.trim();

      if (filename == null || filename.isEmpty || content == null) continue;

      final fullPath = '$folderPath/$filename';

      try {
        await _fileSystemIO.saveFile(fullPath, content);
        files.add(GeneratedFile(filename: filename, path: fullPath));
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to save file $e');
        // Log but do not crash the conversation if a single file fails.
        files.add(GeneratedFile(filename: filename, path: fullPath, error: e.toString()));
      }
    }

    return files;
  }

  /// Translates an arbitrary app name into a safe directory name.
  String _sanitiseFolderName(String appName) {
    return appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  }
}

// ---------------------------------------------------------------------------
// Reply model
// ---------------------------------------------------------------------------

/// Represents a single reply from the [ProgrammingAssistant].
class AssistantReply {
  final String text;

  /// The full, uncleaned LLM response.
  final String rawReply;

  /// `true` when the LLM has completed Phase 3 code generation.
  final bool isCodeFinalized;

  /// Non-empty only when [isCodeFinalized] is `true`.
  final List<GeneratedFile> savedFiles;

  const AssistantReply({
    required this.text,
    required this.rawReply,
    this.isCodeFinalized = false,
    this.savedFiles = const [],
  });
}

/// Metadata about a single file that was extracted from the LLM response
/// and written to the device filesystem.
class GeneratedFile {
  final String filename;
  final String path;

  /// Non-null when the file could not be saved.
  final String? error;

  const GeneratedFile({required this.filename, required this.path, this.error});

  bool get hasSaved => error == null;
}

// ---------------------------------------------------------------------------
// Fallback system prompt (used when the asset is unavailable)
// ---------------------------------------------------------------------------

const String _kFallbackSystemPrompt = '''
You are "WidgetArchitect AI," an expert Full-Stack Web Developer specializing
in creating self-contained, lightweight, and high-performance web widgets
(HTML, CSS, Vanilla JS). Your goal is to turn a user's idea into a fully
functional local web app that runs inside a mobile webview.

Follow this strict 4-phase workflow:
Phase 1: Ask 3-5 clarification questions — do NOT generate code yet.
Phase 2: Present an "App Blueprint" and ask for approval.
Phase 3: Generate complete production-ready code. Each file in its own
         markdown code block starting with /* filename: <name> */.
Phase 4: Debug and iterate on any errors the user reports.
''';
