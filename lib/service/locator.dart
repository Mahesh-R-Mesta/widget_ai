import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_ai/llm/gemin_model.dart';
import 'package:widget_ai/llm/antropic_model.dart';
import 'package:widget_ai/llm/programing_assistant.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/service/file_system.dart';
import 'package:widget_ai/service/home_widget_service.dart';
import 'package:widget_ai/service/native_bridge_service.dart';
import 'package:widget_ai/service/shared_preference.dart';
import 'package:widget_ai/service/web_search_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // ── Shared Preferences ───────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<LocalStorage>(LocalStorage(sharedPreferences));

  // ── File system IO ───────────────────────────────────────────────────────
  locator.registerLazySingleton<FileSystemIO>(() => FileSystemIO());
  locator.registerLazySingleton<HomeWidgetService>(() => HomeWidgetService());
  locator.registerLazySingleton<NativeBridgeService>(() => NativeBridgeService());
  locator.registerLazySingleton<WebSearchService>(() => WebSearchService());

  // ── Drift database ───────────────────────────────────────────────────────
  locator.registerSingleton<AppDatabase>(AppDatabase());

  // ── LLM model ────────────────────────────────────────────────────────────
  locator.registerSingleton<GeminiModel>(GeminiModel(apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''));

  locator.registerSingleton<AnthropicModel>(AnthropicModel(apiKey: dotenv.env['ANTHROPIC_API_KEY'] ?? ''));

  // ── Programming assistant ─────────────────────────────────────────────────
  // Factory so every ChatWindow/Cubit gets its own conversation memory.
  locator.registerFactory<ProgrammingAssistant>(
    () => ProgrammingAssistant(fileSystemIO: locator<FileSystemIO>(), localStorage: locator<LocalStorage>()),
  );
}
