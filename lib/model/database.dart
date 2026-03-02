import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_ai/model/widget_model.dart';

part 'database.g.dart';

@DriftDatabase(tables: [WidgetModel])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Add the two new columns introduced in v2.
        await m.addColumn(widgetModel, widgetModel.iconPath);
        await m.addColumn(widgetModel, widgetModel.chatHistory);
      }
      if (from < 3) {
        await m.addColumn(widgetModel, widgetModel.llmModel);
      }
    },
  );

  static QueryExecutor openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    );
  }

  // ── DAO methods ───────────────────────────────────────────────────────────

  /// Insert a new project and return its auto-generated id.
  Future<int> insertProject(WidgetModelCompanion project) => into(widgetModel).insert(project);

  /// Update an existing project row.
  Future<bool> updateProject(WidgetModelData project) => update(widgetModel).replace(project);

  /// Fetch all projects ordered by id descending (newest first).
  Future<List<WidgetModelData>> getAllProjects() =>
      (select(widgetModel)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();

  /// Watch the full project list reactively.
  Stream<List<WidgetModelData>> watchAllProjects() =>
      (select(widgetModel)..orderBy([(t) => OrderingTerm.desc(t.id)])).watch();

  /// Fetch a single project by its id.
  Future<WidgetModelData?> getProjectById(int id) =>
      (select(widgetModel)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Persist the serialised chat history string for a project.
  Future<void> updateChatHistory(int projectId, String historyJson) => (update(
    widgetModel,
  )..where((t) => t.id.equals(projectId))).write(WidgetModelCompanion(chatHistory: Value(historyJson)));

  /// Update the resolved folder location (set after code generation).
  Future<void> updateProjectLocation(int projectId, String folderPath) => (update(
    widgetModel,
  )..where((t) => t.id.equals(projectId))).write(WidgetModelCompanion(location: Value(folderPath)));

  /// Delete a project by its id.
  Future<int> deleteProject(int id) => (delete(widgetModel)..where((t) => t.id.equals(id))).go();
}
