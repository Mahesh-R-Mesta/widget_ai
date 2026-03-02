// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WidgetModelTable extends WidgetModel
    with TableInfo<$WidgetModelTable, WidgetModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetModelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatHistoryMeta = const VerificationMeta(
    'chatHistory',
  );
  @override
  late final GeneratedColumn<String> chatHistory = GeneratedColumn<String>(
    'chat_history',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _llmModelMeta = const VerificationMeta(
    'llmModel',
  );
  @override
  late final GeneratedColumn<String> llmModel = GeneratedColumn<String>(
    'llm_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gemini'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    location,
    type,
    iconPath,
    chatHistory,
    llmModel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_model';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetModelData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('chat_history')) {
      context.handle(
        _chatHistoryMeta,
        chatHistory.isAcceptableOrUnknown(
          data['chat_history']!,
          _chatHistoryMeta,
        ),
      );
    }
    if (data.containsKey('llm_model')) {
      context.handle(
        _llmModelMeta,
        llmModel.isAcceptableOrUnknown(data['llm_model']!, _llmModelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WidgetModelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetModelData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      chatHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_history'],
      ),
      llmModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_model'],
      )!,
    );
  }

  @override
  $WidgetModelTable createAlias(String alias) {
    return $WidgetModelTable(attachedDatabase, alias);
  }
}

class WidgetModelData extends DataClass implements Insertable<WidgetModelData> {
  final int id;
  final String name;
  final String description;
  final String? location;
  final String? type;
  final String? iconPath;
  final String? chatHistory;
  final String llmModel;
  const WidgetModelData({
    required this.id,
    required this.name,
    required this.description,
    this.location,
    this.type,
    this.iconPath,
    this.chatHistory,
    required this.llmModel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    if (!nullToAbsent || chatHistory != null) {
      map['chat_history'] = Variable<String>(chatHistory);
    }
    map['llm_model'] = Variable<String>(llmModel);
    return map;
  }

  WidgetModelCompanion toCompanion(bool nullToAbsent) {
    return WidgetModelCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      iconPath: iconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(iconPath),
      chatHistory: chatHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(chatHistory),
      llmModel: Value(llmModel),
    );
  }

  factory WidgetModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetModelData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      location: serializer.fromJson<String?>(json['location']),
      type: serializer.fromJson<String?>(json['type']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      chatHistory: serializer.fromJson<String?>(json['chatHistory']),
      llmModel: serializer.fromJson<String>(json['llmModel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'location': serializer.toJson<String?>(location),
      'type': serializer.toJson<String?>(type),
      'iconPath': serializer.toJson<String?>(iconPath),
      'chatHistory': serializer.toJson<String?>(chatHistory),
      'llmModel': serializer.toJson<String>(llmModel),
    };
  }

  WidgetModelData copyWith({
    int? id,
    String? name,
    String? description,
    Value<String?> location = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> iconPath = const Value.absent(),
    Value<String?> chatHistory = const Value.absent(),
    String? llmModel,
  }) => WidgetModelData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    location: location.present ? location.value : this.location,
    type: type.present ? type.value : this.type,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    chatHistory: chatHistory.present ? chatHistory.value : this.chatHistory,
    llmModel: llmModel ?? this.llmModel,
  );
  WidgetModelData copyWithCompanion(WidgetModelCompanion data) {
    return WidgetModelData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      type: data.type.present ? data.type.value : this.type,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      chatHistory: data.chatHistory.present
          ? data.chatHistory.value
          : this.chatHistory,
      llmModel: data.llmModel.present ? data.llmModel.value : this.llmModel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetModelData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('type: $type, ')
          ..write('iconPath: $iconPath, ')
          ..write('chatHistory: $chatHistory, ')
          ..write('llmModel: $llmModel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    location,
    type,
    iconPath,
    chatHistory,
    llmModel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetModelData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.location == this.location &&
          other.type == this.type &&
          other.iconPath == this.iconPath &&
          other.chatHistory == this.chatHistory &&
          other.llmModel == this.llmModel);
}

class WidgetModelCompanion extends UpdateCompanion<WidgetModelData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> location;
  final Value<String?> type;
  final Value<String?> iconPath;
  final Value<String?> chatHistory;
  final Value<String> llmModel;
  const WidgetModelCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.type = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.chatHistory = const Value.absent(),
    this.llmModel = const Value.absent(),
  });
  WidgetModelCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
    this.location = const Value.absent(),
    this.type = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.chatHistory = const Value.absent(),
    this.llmModel = const Value.absent(),
  }) : name = Value(name),
       description = Value(description);
  static Insertable<WidgetModelData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? location,
    Expression<String>? type,
    Expression<String>? iconPath,
    Expression<String>? chatHistory,
    Expression<String>? llmModel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (type != null) 'type': type,
      if (iconPath != null) 'icon_path': iconPath,
      if (chatHistory != null) 'chat_history': chatHistory,
      if (llmModel != null) 'llm_model': llmModel,
    });
  }

  WidgetModelCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? location,
    Value<String?>? type,
    Value<String?>? iconPath,
    Value<String?>? chatHistory,
    Value<String>? llmModel,
  }) {
    return WidgetModelCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      chatHistory: chatHistory ?? this.chatHistory,
      llmModel: llmModel ?? this.llmModel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (chatHistory.present) {
      map['chat_history'] = Variable<String>(chatHistory.value);
    }
    if (llmModel.present) {
      map['llm_model'] = Variable<String>(llmModel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetModelCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('type: $type, ')
          ..write('iconPath: $iconPath, ')
          ..write('chatHistory: $chatHistory, ')
          ..write('llmModel: $llmModel')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WidgetModelTable widgetModel = $WidgetModelTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [widgetModel];
}

typedef $$WidgetModelTableCreateCompanionBuilder =
    WidgetModelCompanion Function({
      Value<int> id,
      required String name,
      required String description,
      Value<String?> location,
      Value<String?> type,
      Value<String?> iconPath,
      Value<String?> chatHistory,
      Value<String> llmModel,
    });
typedef $$WidgetModelTableUpdateCompanionBuilder =
    WidgetModelCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String?> location,
      Value<String?> type,
      Value<String?> iconPath,
      Value<String?> chatHistory,
      Value<String> llmModel,
    });

class $$WidgetModelTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetModelTable> {
  $$WidgetModelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatHistory => $composableBuilder(
    column: $table.chatHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmModel => $composableBuilder(
    column: $table.llmModel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetModelTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetModelTable> {
  $$WidgetModelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatHistory => $composableBuilder(
    column: $table.chatHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmModel => $composableBuilder(
    column: $table.llmModel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetModelTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetModelTable> {
  $$WidgetModelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<String> get chatHistory => $composableBuilder(
    column: $table.chatHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmModel =>
      $composableBuilder(column: $table.llmModel, builder: (column) => column);
}

class $$WidgetModelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetModelTable,
          WidgetModelData,
          $$WidgetModelTableFilterComposer,
          $$WidgetModelTableOrderingComposer,
          $$WidgetModelTableAnnotationComposer,
          $$WidgetModelTableCreateCompanionBuilder,
          $$WidgetModelTableUpdateCompanionBuilder,
          (
            WidgetModelData,
            BaseReferences<_$AppDatabase, $WidgetModelTable, WidgetModelData>,
          ),
          WidgetModelData,
          PrefetchHooks Function()
        > {
  $$WidgetModelTableTableManager(_$AppDatabase db, $WidgetModelTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetModelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetModelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetModelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> chatHistory = const Value.absent(),
                Value<String> llmModel = const Value.absent(),
              }) => WidgetModelCompanion(
                id: id,
                name: name,
                description: description,
                location: location,
                type: type,
                iconPath: iconPath,
                chatHistory: chatHistory,
                llmModel: llmModel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
                Value<String?> location = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> chatHistory = const Value.absent(),
                Value<String> llmModel = const Value.absent(),
              }) => WidgetModelCompanion.insert(
                id: id,
                name: name,
                description: description,
                location: location,
                type: type,
                iconPath: iconPath,
                chatHistory: chatHistory,
                llmModel: llmModel,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetModelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetModelTable,
      WidgetModelData,
      $$WidgetModelTableFilterComposer,
      $$WidgetModelTableOrderingComposer,
      $$WidgetModelTableAnnotationComposer,
      $$WidgetModelTableCreateCompanionBuilder,
      $$WidgetModelTableUpdateCompanionBuilder,
      (
        WidgetModelData,
        BaseReferences<_$AppDatabase, $WidgetModelTable, WidgetModelData>,
      ),
      WidgetModelData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WidgetModelTableTableManager get widgetModel =>
      $$WidgetModelTableTableManager(_db, _db.widgetModel);
}
