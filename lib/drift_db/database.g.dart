// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventListenerTable extends EventListener
    with TableInfo<$EventListenerTable, EventListenerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventListenerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _websiteURlMeta =
      const VerificationMeta('websiteURl');
  @override
  late final GeneratedColumn<String> websiteURl = GeneratedColumn<String>(
      'website', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inTimeMeta = const VerificationMeta('inTime');
  @override
  late final GeneratedColumn<String> inTime = GeneratedColumn<String>(
      'in_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _liveMeta = const VerificationMeta('live');
  @override
  late final GeneratedColumn<bool> live = GeneratedColumn<bool>(
      'live', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("live" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, websiteURl, inTime, live];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_listener';
  @override
  VerificationContext validateIntegrity(Insertable<EventListenerData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('website')) {
      context.handle(_websiteURlMeta,
          websiteURl.isAcceptableOrUnknown(data['website']!, _websiteURlMeta));
    } else if (isInserting) {
      context.missing(_websiteURlMeta);
    }
    if (data.containsKey('in_time')) {
      context.handle(_inTimeMeta,
          inTime.isAcceptableOrUnknown(data['in_time']!, _inTimeMeta));
    } else if (isInserting) {
      context.missing(_inTimeMeta);
    }
    if (data.containsKey('live')) {
      context.handle(
          _liveMeta, live.isAcceptableOrUnknown(data['live']!, _liveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventListenerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventListenerData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      websiteURl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website'])!,
      inTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}in_time'])!,
      live: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}live'])!,
    );
  }

  @override
  $EventListenerTable createAlias(String alias) {
    return $EventListenerTable(attachedDatabase, alias);
  }
}

class EventListenerData extends DataClass
    implements Insertable<EventListenerData> {
  final int id;
  final String websiteURl;
  final String inTime;
  final bool live;
  const EventListenerData(
      {required this.id,
      required this.websiteURl,
      required this.inTime,
      required this.live});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['website'] = Variable<String>(websiteURl);
    map['in_time'] = Variable<String>(inTime);
    map['live'] = Variable<bool>(live);
    return map;
  }

  EventListenerCompanion toCompanion(bool nullToAbsent) {
    return EventListenerCompanion(
      id: Value(id),
      websiteURl: Value(websiteURl),
      inTime: Value(inTime),
      live: Value(live),
    );
  }

  factory EventListenerData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventListenerData(
      id: serializer.fromJson<int>(json['id']),
      websiteURl: serializer.fromJson<String>(json['websiteURl']),
      inTime: serializer.fromJson<String>(json['inTime']),
      live: serializer.fromJson<bool>(json['live']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'websiteURl': serializer.toJson<String>(websiteURl),
      'inTime': serializer.toJson<String>(inTime),
      'live': serializer.toJson<bool>(live),
    };
  }

  EventListenerData copyWith(
          {int? id, String? websiteURl, String? inTime, bool? live}) =>
      EventListenerData(
        id: id ?? this.id,
        websiteURl: websiteURl ?? this.websiteURl,
        inTime: inTime ?? this.inTime,
        live: live ?? this.live,
      );
  EventListenerData copyWithCompanion(EventListenerCompanion data) {
    return EventListenerData(
      id: data.id.present ? data.id.value : this.id,
      websiteURl:
          data.websiteURl.present ? data.websiteURl.value : this.websiteURl,
      inTime: data.inTime.present ? data.inTime.value : this.inTime,
      live: data.live.present ? data.live.value : this.live,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventListenerData(')
          ..write('id: $id, ')
          ..write('websiteURl: $websiteURl, ')
          ..write('inTime: $inTime, ')
          ..write('live: $live')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, websiteURl, inTime, live);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventListenerData &&
          other.id == this.id &&
          other.websiteURl == this.websiteURl &&
          other.inTime == this.inTime &&
          other.live == this.live);
}

class EventListenerCompanion extends UpdateCompanion<EventListenerData> {
  final Value<int> id;
  final Value<String> websiteURl;
  final Value<String> inTime;
  final Value<bool> live;
  const EventListenerCompanion({
    this.id = const Value.absent(),
    this.websiteURl = const Value.absent(),
    this.inTime = const Value.absent(),
    this.live = const Value.absent(),
  });
  EventListenerCompanion.insert({
    this.id = const Value.absent(),
    required String websiteURl,
    required String inTime,
    this.live = const Value.absent(),
  })  : websiteURl = Value(websiteURl),
        inTime = Value(inTime);
  static Insertable<EventListenerData> custom({
    Expression<int>? id,
    Expression<String>? websiteURl,
    Expression<String>? inTime,
    Expression<bool>? live,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (websiteURl != null) 'website': websiteURl,
      if (inTime != null) 'in_time': inTime,
      if (live != null) 'live': live,
    });
  }

  EventListenerCompanion copyWith(
      {Value<int>? id,
      Value<String>? websiteURl,
      Value<String>? inTime,
      Value<bool>? live}) {
    return EventListenerCompanion(
      id: id ?? this.id,
      websiteURl: websiteURl ?? this.websiteURl,
      inTime: inTime ?? this.inTime,
      live: live ?? this.live,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (websiteURl.present) {
      map['website'] = Variable<String>(websiteURl.value);
    }
    if (inTime.present) {
      map['in_time'] = Variable<String>(inTime.value);
    }
    if (live.present) {
      map['live'] = Variable<bool>(live.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventListenerCompanion(')
          ..write('id: $id, ')
          ..write('websiteURl: $websiteURl, ')
          ..write('inTime: $inTime, ')
          ..write('live: $live')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventListenerTable eventListener = $EventListenerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [eventListener];
}

typedef $$EventListenerTableCreateCompanionBuilder = EventListenerCompanion
    Function({
  Value<int> id,
  required String websiteURl,
  required String inTime,
  Value<bool> live,
});
typedef $$EventListenerTableUpdateCompanionBuilder = EventListenerCompanion
    Function({
  Value<int> id,
  Value<String> websiteURl,
  Value<String> inTime,
  Value<bool> live,
});

class $$EventListenerTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventListenerTable,
    EventListenerData,
    $$EventListenerTableFilterComposer,
    $$EventListenerTableOrderingComposer,
    $$EventListenerTableCreateCompanionBuilder,
    $$EventListenerTableUpdateCompanionBuilder> {
  $$EventListenerTableTableManager(_$AppDatabase db, $EventListenerTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EventListenerTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EventListenerTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> websiteURl = const Value.absent(),
            Value<String> inTime = const Value.absent(),
            Value<bool> live = const Value.absent(),
          }) =>
              EventListenerCompanion(
            id: id,
            websiteURl: websiteURl,
            inTime: inTime,
            live: live,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String websiteURl,
            required String inTime,
            Value<bool> live = const Value.absent(),
          }) =>
              EventListenerCompanion.insert(
            id: id,
            websiteURl: websiteURl,
            inTime: inTime,
            live: live,
          ),
        ));
}

class $$EventListenerTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EventListenerTable> {
  $$EventListenerTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get websiteURl => $state.composableBuilder(
      column: $state.table.websiteURl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get inTime => $state.composableBuilder(
      column: $state.table.inTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get live => $state.composableBuilder(
      column: $state.table.live,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EventListenerTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EventListenerTable> {
  $$EventListenerTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get websiteURl => $state.composableBuilder(
      column: $state.table.websiteURl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get inTime => $state.composableBuilder(
      column: $state.table.inTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get live => $state.composableBuilder(
      column: $state.table.live,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventListenerTableTableManager get eventListener =>
      $$EventListenerTableTableManager(_db, _db.eventListener);
}
