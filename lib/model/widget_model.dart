import 'package:drift/drift.dart';

class WidgetModel extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get location => text().nullable()();
  TextColumn get type => text().nullable()();
  // Absolute path to the user-selected/uploaded icon image.
  TextColumn get iconPath => text().nullable()();
  // JSON-encoded list of ChatMessage maps for conversation history.
  TextColumn get chatHistory => text().nullable()();
  // Name of the LLM model used (e.g., 'gemini', 'anthropic').
  TextColumn get llmModel => text().withDefault(const Constant('gemini'))();
}
