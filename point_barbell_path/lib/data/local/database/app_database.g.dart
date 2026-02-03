// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _exerciseTypeMeta = const VerificationMeta(
    'exerciseType',
  );
  @override
  late final GeneratedColumn<String> exerciseType = GeneratedColumn<String>(
    'exercise_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalRepsMeta = const VerificationMeta(
    'totalReps',
  );
  @override
  late final GeneratedColumn<int> totalReps = GeneratedColumn<int>(
    'total_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSetsMeta = const VerificationMeta(
    'totalSets',
  );
  @override
  late final GeneratedColumn<int> totalSets = GeneratedColumn<int>(
    'total_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgVelocityMeta = const VerificationMeta(
    'avgVelocity',
  );
  @override
  late final GeneratedColumn<double> avgVelocity = GeneratedColumn<double>(
    'avg_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _peakVelocityMeta = const VerificationMeta(
    'peakVelocity',
  );
  @override
  late final GeneratedColumn<double> peakVelocity = GeneratedColumn<double>(
    'peak_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _videoPathMeta = const VerificationMeta(
    'videoPath',
  );
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
    'video_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    exerciseType,
    startedAt,
    endedAt,
    totalReps,
    totalSets,
    avgVelocity,
    peakVelocity,
    notes,
    videoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('exercise_type')) {
      context.handle(
        _exerciseTypeMeta,
        exerciseType.isAcceptableOrUnknown(
          data['exercise_type']!,
          _exerciseTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTypeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('total_reps')) {
      context.handle(
        _totalRepsMeta,
        totalReps.isAcceptableOrUnknown(data['total_reps']!, _totalRepsMeta),
      );
    }
    if (data.containsKey('total_sets')) {
      context.handle(
        _totalSetsMeta,
        totalSets.isAcceptableOrUnknown(data['total_sets']!, _totalSetsMeta),
      );
    }
    if (data.containsKey('avg_velocity')) {
      context.handle(
        _avgVelocityMeta,
        avgVelocity.isAcceptableOrUnknown(
          data['avg_velocity']!,
          _avgVelocityMeta,
        ),
      );
    }
    if (data.containsKey('peak_velocity')) {
      context.handle(
        _peakVelocityMeta,
        peakVelocity.isAcceptableOrUnknown(
          data['peak_velocity']!,
          _peakVelocityMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('video_path')) {
      context.handle(
        _videoPathMeta,
        videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      exerciseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_type'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      totalReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_reps'],
      )!,
      totalSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sets'],
      )!,
      avgVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_velocity'],
      )!,
      peakVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_velocity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      videoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_path'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String uuid;
  final String exerciseType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalReps;
  final int totalSets;
  final double avgVelocity;
  final double peakVelocity;
  final String notes;
  final String? videoPath;
  const Session({
    required this.id,
    required this.uuid,
    required this.exerciseType,
    required this.startedAt,
    this.endedAt,
    required this.totalReps,
    required this.totalSets,
    required this.avgVelocity,
    required this.peakVelocity,
    required this.notes,
    this.videoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['exercise_type'] = Variable<String>(exerciseType);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['total_reps'] = Variable<int>(totalReps);
    map['total_sets'] = Variable<int>(totalSets);
    map['avg_velocity'] = Variable<double>(avgVelocity);
    map['peak_velocity'] = Variable<double>(peakVelocity);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || videoPath != null) {
      map['video_path'] = Variable<String>(videoPath);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      exerciseType: Value(exerciseType),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      totalReps: Value(totalReps),
      totalSets: Value(totalSets),
      avgVelocity: Value(avgVelocity),
      peakVelocity: Value(peakVelocity),
      notes: Value(notes),
      videoPath: videoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(videoPath),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      exerciseType: serializer.fromJson<String>(json['exerciseType']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      totalReps: serializer.fromJson<int>(json['totalReps']),
      totalSets: serializer.fromJson<int>(json['totalSets']),
      avgVelocity: serializer.fromJson<double>(json['avgVelocity']),
      peakVelocity: serializer.fromJson<double>(json['peakVelocity']),
      notes: serializer.fromJson<String>(json['notes']),
      videoPath: serializer.fromJson<String?>(json['videoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'exerciseType': serializer.toJson<String>(exerciseType),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'totalReps': serializer.toJson<int>(totalReps),
      'totalSets': serializer.toJson<int>(totalSets),
      'avgVelocity': serializer.toJson<double>(avgVelocity),
      'peakVelocity': serializer.toJson<double>(peakVelocity),
      'notes': serializer.toJson<String>(notes),
      'videoPath': serializer.toJson<String?>(videoPath),
    };
  }

  Session copyWith({
    int? id,
    String? uuid,
    String? exerciseType,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? totalReps,
    int? totalSets,
    double? avgVelocity,
    double? peakVelocity,
    String? notes,
    Value<String?> videoPath = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    exerciseType: exerciseType ?? this.exerciseType,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    totalReps: totalReps ?? this.totalReps,
    totalSets: totalSets ?? this.totalSets,
    avgVelocity: avgVelocity ?? this.avgVelocity,
    peakVelocity: peakVelocity ?? this.peakVelocity,
    notes: notes ?? this.notes,
    videoPath: videoPath.present ? videoPath.value : this.videoPath,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      totalReps: data.totalReps.present ? data.totalReps.value : this.totalReps,
      totalSets: data.totalSets.present ? data.totalSets.value : this.totalSets,
      avgVelocity: data.avgVelocity.present
          ? data.avgVelocity.value
          : this.avgVelocity,
      peakVelocity: data.peakVelocity.present
          ? data.peakVelocity.value
          : this.peakVelocity,
      notes: data.notes.present ? data.notes.value : this.notes,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalReps: $totalReps, ')
          ..write('totalSets: $totalSets, ')
          ..write('avgVelocity: $avgVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('notes: $notes, ')
          ..write('videoPath: $videoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    exerciseType,
    startedAt,
    endedAt,
    totalReps,
    totalSets,
    avgVelocity,
    peakVelocity,
    notes,
    videoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.exerciseType == this.exerciseType &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.totalReps == this.totalReps &&
          other.totalSets == this.totalSets &&
          other.avgVelocity == this.avgVelocity &&
          other.peakVelocity == this.peakVelocity &&
          other.notes == this.notes &&
          other.videoPath == this.videoPath);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> exerciseType;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> totalReps;
  final Value<int> totalSets;
  final Value<double> avgVelocity;
  final Value<double> peakVelocity;
  final Value<String> notes;
  final Value<String?> videoPath;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalReps = const Value.absent(),
    this.totalSets = const Value.absent(),
    this.avgVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.notes = const Value.absent(),
    this.videoPath = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String exerciseType,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.totalReps = const Value.absent(),
    this.totalSets = const Value.absent(),
    this.avgVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.notes = const Value.absent(),
    this.videoPath = const Value.absent(),
  }) : uuid = Value(uuid),
       exerciseType = Value(exerciseType),
       startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? exerciseType,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? totalReps,
    Expression<int>? totalSets,
    Expression<double>? avgVelocity,
    Expression<double>? peakVelocity,
    Expression<String>? notes,
    Expression<String>? videoPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (totalReps != null) 'total_reps': totalReps,
      if (totalSets != null) 'total_sets': totalSets,
      if (avgVelocity != null) 'avg_velocity': avgVelocity,
      if (peakVelocity != null) 'peak_velocity': peakVelocity,
      if (notes != null) 'notes': notes,
      if (videoPath != null) 'video_path': videoPath,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? exerciseType,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? totalReps,
    Value<int>? totalSets,
    Value<double>? avgVelocity,
    Value<double>? peakVelocity,
    Value<String>? notes,
    Value<String?>? videoPath,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      exerciseType: exerciseType ?? this.exerciseType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalReps: totalReps ?? this.totalReps,
      totalSets: totalSets ?? this.totalSets,
      avgVelocity: avgVelocity ?? this.avgVelocity,
      peakVelocity: peakVelocity ?? this.peakVelocity,
      notes: notes ?? this.notes,
      videoPath: videoPath ?? this.videoPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<String>(exerciseType.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (totalReps.present) {
      map['total_reps'] = Variable<int>(totalReps.value);
    }
    if (totalSets.present) {
      map['total_sets'] = Variable<int>(totalSets.value);
    }
    if (avgVelocity.present) {
      map['avg_velocity'] = Variable<double>(avgVelocity.value);
    }
    if (peakVelocity.present) {
      map['peak_velocity'] = Variable<double>(peakVelocity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalReps: $totalReps, ')
          ..write('totalSets: $totalSets, ')
          ..write('avgVelocity: $avgVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('notes: $notes, ')
          ..write('videoPath: $videoPath')
          ..write(')'))
        .toString();
  }
}

class $SessionSetsTable extends SessionSets
    with TableInfo<$SessionSetsTable, SessionSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repCountMeta = const VerificationMeta(
    'repCount',
  );
  @override
  late final GeneratedColumn<int> repCount = GeneratedColumn<int>(
    'rep_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgVelocityMeta = const VerificationMeta(
    'avgVelocity',
  );
  @override
  late final GeneratedColumn<double> avgVelocity = GeneratedColumn<double>(
    'avg_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _peakVelocityMeta = const VerificationMeta(
    'peakVelocity',
  );
  @override
  late final GeneratedColumn<double> peakVelocity = GeneratedColumn<double>(
    'peak_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _romMeta = const VerificationMeta('rom');
  @override
  late final GeneratedColumn<double> rom = GeneratedColumn<double>(
    'rom',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathDataJsonMeta = const VerificationMeta(
    'pathDataJson',
  );
  @override
  late final GeneratedColumn<String> pathDataJson = GeneratedColumn<String>(
    'path_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    setNumber,
    repCount,
    avgVelocity,
    peakVelocity,
    rom,
    startedAt,
    endedAt,
    pathDataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('rep_count')) {
      context.handle(
        _repCountMeta,
        repCount.isAcceptableOrUnknown(data['rep_count']!, _repCountMeta),
      );
    }
    if (data.containsKey('avg_velocity')) {
      context.handle(
        _avgVelocityMeta,
        avgVelocity.isAcceptableOrUnknown(
          data['avg_velocity']!,
          _avgVelocityMeta,
        ),
      );
    }
    if (data.containsKey('peak_velocity')) {
      context.handle(
        _peakVelocityMeta,
        peakVelocity.isAcceptableOrUnknown(
          data['peak_velocity']!,
          _peakVelocityMeta,
        ),
      );
    }
    if (data.containsKey('rom')) {
      context.handle(
        _romMeta,
        rom.isAcceptableOrUnknown(data['rom']!, _romMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('path_data_json')) {
      context.handle(
        _pathDataJsonMeta,
        pathDataJson.isAcceptableOrUnknown(
          data['path_data_json']!,
          _pathDataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      repCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_count'],
      )!,
      avgVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_velocity'],
      )!,
      peakVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_velocity'],
      )!,
      rom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rom'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      pathDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path_data_json'],
      )!,
    );
  }

  @override
  $SessionSetsTable createAlias(String alias) {
    return $SessionSetsTable(attachedDatabase, alias);
  }
}

class SessionSet extends DataClass implements Insertable<SessionSet> {
  final int id;
  final int sessionId;
  final int setNumber;
  final int repCount;
  final double avgVelocity;
  final double peakVelocity;
  final double rom;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String pathDataJson;
  const SessionSet({
    required this.id,
    required this.sessionId,
    required this.setNumber,
    required this.repCount,
    required this.avgVelocity,
    required this.peakVelocity,
    required this.rom,
    required this.startedAt,
    this.endedAt,
    required this.pathDataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['set_number'] = Variable<int>(setNumber);
    map['rep_count'] = Variable<int>(repCount);
    map['avg_velocity'] = Variable<double>(avgVelocity);
    map['peak_velocity'] = Variable<double>(peakVelocity);
    map['rom'] = Variable<double>(rom);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['path_data_json'] = Variable<String>(pathDataJson);
    return map;
  }

  SessionSetsCompanion toCompanion(bool nullToAbsent) {
    return SessionSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      setNumber: Value(setNumber),
      repCount: Value(repCount),
      avgVelocity: Value(avgVelocity),
      peakVelocity: Value(peakVelocity),
      rom: Value(rom),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      pathDataJson: Value(pathDataJson),
    );
  }

  factory SessionSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSet(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      repCount: serializer.fromJson<int>(json['repCount']),
      avgVelocity: serializer.fromJson<double>(json['avgVelocity']),
      peakVelocity: serializer.fromJson<double>(json['peakVelocity']),
      rom: serializer.fromJson<double>(json['rom']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      pathDataJson: serializer.fromJson<String>(json['pathDataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'setNumber': serializer.toJson<int>(setNumber),
      'repCount': serializer.toJson<int>(repCount),
      'avgVelocity': serializer.toJson<double>(avgVelocity),
      'peakVelocity': serializer.toJson<double>(peakVelocity),
      'rom': serializer.toJson<double>(rom),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'pathDataJson': serializer.toJson<String>(pathDataJson),
    };
  }

  SessionSet copyWith({
    int? id,
    int? sessionId,
    int? setNumber,
    int? repCount,
    double? avgVelocity,
    double? peakVelocity,
    double? rom,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? pathDataJson,
  }) => SessionSet(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    setNumber: setNumber ?? this.setNumber,
    repCount: repCount ?? this.repCount,
    avgVelocity: avgVelocity ?? this.avgVelocity,
    peakVelocity: peakVelocity ?? this.peakVelocity,
    rom: rom ?? this.rom,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    pathDataJson: pathDataJson ?? this.pathDataJson,
  );
  SessionSet copyWithCompanion(SessionSetsCompanion data) {
    return SessionSet(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      repCount: data.repCount.present ? data.repCount.value : this.repCount,
      avgVelocity: data.avgVelocity.present
          ? data.avgVelocity.value
          : this.avgVelocity,
      peakVelocity: data.peakVelocity.present
          ? data.peakVelocity.value
          : this.peakVelocity,
      rom: data.rom.present ? data.rom.value : this.rom,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      pathDataJson: data.pathDataJson.present
          ? data.pathDataJson.value
          : this.pathDataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSet(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setNumber: $setNumber, ')
          ..write('repCount: $repCount, ')
          ..write('avgVelocity: $avgVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('rom: $rom, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pathDataJson: $pathDataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    setNumber,
    repCount,
    avgVelocity,
    peakVelocity,
    rom,
    startedAt,
    endedAt,
    pathDataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSet &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.setNumber == this.setNumber &&
          other.repCount == this.repCount &&
          other.avgVelocity == this.avgVelocity &&
          other.peakVelocity == this.peakVelocity &&
          other.rom == this.rom &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.pathDataJson == this.pathDataJson);
}

class SessionSetsCompanion extends UpdateCompanion<SessionSet> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> setNumber;
  final Value<int> repCount;
  final Value<double> avgVelocity;
  final Value<double> peakVelocity;
  final Value<double> rom;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> pathDataJson;
  const SessionSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.repCount = const Value.absent(),
    this.avgVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.rom = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.pathDataJson = const Value.absent(),
  });
  SessionSetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int setNumber,
    this.repCount = const Value.absent(),
    this.avgVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.rom = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.pathDataJson = const Value.absent(),
  }) : sessionId = Value(sessionId),
       setNumber = Value(setNumber),
       startedAt = Value(startedAt);
  static Insertable<SessionSet> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? setNumber,
    Expression<int>? repCount,
    Expression<double>? avgVelocity,
    Expression<double>? peakVelocity,
    Expression<double>? rom,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? pathDataJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (setNumber != null) 'set_number': setNumber,
      if (repCount != null) 'rep_count': repCount,
      if (avgVelocity != null) 'avg_velocity': avgVelocity,
      if (peakVelocity != null) 'peak_velocity': peakVelocity,
      if (rom != null) 'rom': rom,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (pathDataJson != null) 'path_data_json': pathDataJson,
    });
  }

  SessionSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? setNumber,
    Value<int>? repCount,
    Value<double>? avgVelocity,
    Value<double>? peakVelocity,
    Value<double>? rom,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? pathDataJson,
  }) {
    return SessionSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      setNumber: setNumber ?? this.setNumber,
      repCount: repCount ?? this.repCount,
      avgVelocity: avgVelocity ?? this.avgVelocity,
      peakVelocity: peakVelocity ?? this.peakVelocity,
      rom: rom ?? this.rom,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pathDataJson: pathDataJson ?? this.pathDataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (repCount.present) {
      map['rep_count'] = Variable<int>(repCount.value);
    }
    if (avgVelocity.present) {
      map['avg_velocity'] = Variable<double>(avgVelocity.value);
    }
    if (peakVelocity.present) {
      map['peak_velocity'] = Variable<double>(peakVelocity.value);
    }
    if (rom.present) {
      map['rom'] = Variable<double>(rom.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (pathDataJson.present) {
      map['path_data_json'] = Variable<String>(pathDataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setNumber: $setNumber, ')
          ..write('repCount: $repCount, ')
          ..write('avgVelocity: $avgVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('rom: $rom, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pathDataJson: $pathDataJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionSetsTable sessionSets = $SessionSetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions, sessionSets];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String uuid,
      required String exerciseType,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalReps,
      Value<int> totalSets,
      Value<double> avgVelocity,
      Value<double> peakVelocity,
      Value<String> notes,
      Value<String?> videoPath,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> exerciseType,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalReps,
      Value<int> totalSets,
      Value<double> avgVelocity,
      Value<double> peakVelocity,
      Value<String> notes,
      Value<String?> videoPath,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionSetsTable, List<SessionSet>>
  _sessionSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionSets,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.sessionSets.sessionId),
  );

  $$SessionSetsTableProcessedTableManager get sessionSetsRefs {
    final manager = $$SessionSetsTableTableManager(
      $_db,
      $_db.sessionSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalReps => $composableBuilder(
    column: $table.totalReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoPath => $composableBuilder(
    column: $table.videoPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionSetsRefs(
    Expression<bool> Function($$SessionSetsTableFilterComposer f) f,
  ) {
    final $$SessionSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSetsTableFilterComposer(
            $db: $db,
            $table: $db.sessionSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalReps => $composableBuilder(
    column: $table.totalReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoPath => $composableBuilder(
    column: $table.videoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get totalReps =>
      $composableBuilder(column: $table.totalReps, builder: (column) => column);

  GeneratedColumn<int> get totalSets =>
      $composableBuilder(column: $table.totalSets, builder: (column) => column);

  GeneratedColumn<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  Expression<T> sessionSetsRefs<T extends Object>(
    Expression<T> Function($$SessionSetsTableAnnotationComposer a) f,
  ) {
    final $$SessionSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool sessionSetsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> exerciseType = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalReps = const Value.absent(),
                Value<int> totalSets = const Value.absent(),
                Value<double> avgVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> videoPath = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                uuid: uuid,
                exerciseType: exerciseType,
                startedAt: startedAt,
                endedAt: endedAt,
                totalReps: totalReps,
                totalSets: totalSets,
                avgVelocity: avgVelocity,
                peakVelocity: peakVelocity,
                notes: notes,
                videoPath: videoPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String exerciseType,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalReps = const Value.absent(),
                Value<int> totalSets = const Value.absent(),
                Value<double> avgVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> videoPath = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                uuid: uuid,
                exerciseType: exerciseType,
                startedAt: startedAt,
                endedAt: endedAt,
                totalReps: totalReps,
                totalSets: totalSets,
                avgVelocity: avgVelocity,
                peakVelocity: peakVelocity,
                notes: notes,
                videoPath: videoPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionSetsRefs) db.sessionSets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionSetsRefs)
                    await $_getPrefetchedData<
                      Session,
                      $SessionsTable,
                      SessionSet
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._sessionSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionsTableReferences(
                        db,
                        table,
                        p0,
                      ).sessionSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool sessionSetsRefs})
    >;
typedef $$SessionSetsTableCreateCompanionBuilder =
    SessionSetsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int setNumber,
      Value<int> repCount,
      Value<double> avgVelocity,
      Value<double> peakVelocity,
      Value<double> rom,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String> pathDataJson,
    });
typedef $$SessionSetsTableUpdateCompanionBuilder =
    SessionSetsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> setNumber,
      Value<int> repCount,
      Value<double> avgVelocity,
      Value<double> peakVelocity,
      Value<double> rom,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> pathDataJson,
    });

final class $$SessionSetsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSet> {
  $$SessionSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.sessionSets.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionSetsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableFilterComposer({
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

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repCount => $composableBuilder(
    column: $table.repCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rom => $composableBuilder(
    column: $table.rom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathDataJson => $composableBuilder(
    column: $table.pathDataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableOrderingComposer({
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

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repCount => $composableBuilder(
    column: $table.repCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rom => $composableBuilder(
    column: $table.rom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathDataJson => $composableBuilder(
    column: $table.pathDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<int> get repCount =>
      $composableBuilder(column: $table.repCount, builder: (column) => column);

  GeneratedColumn<double> get avgVelocity => $composableBuilder(
    column: $table.avgVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rom =>
      $composableBuilder(column: $table.rom, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get pathDataJson => $composableBuilder(
    column: $table.pathDataJson,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSetsTable,
          SessionSet,
          $$SessionSetsTableFilterComposer,
          $$SessionSetsTableOrderingComposer,
          $$SessionSetsTableAnnotationComposer,
          $$SessionSetsTableCreateCompanionBuilder,
          $$SessionSetsTableUpdateCompanionBuilder,
          (SessionSet, $$SessionSetsTableReferences),
          SessionSet,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionSetsTableTableManager(_$AppDatabase db, $SessionSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<int> repCount = const Value.absent(),
                Value<double> avgVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<double> rom = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> pathDataJson = const Value.absent(),
              }) => SessionSetsCompanion(
                id: id,
                sessionId: sessionId,
                setNumber: setNumber,
                repCount: repCount,
                avgVelocity: avgVelocity,
                peakVelocity: peakVelocity,
                rom: rom,
                startedAt: startedAt,
                endedAt: endedAt,
                pathDataJson: pathDataJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int setNumber,
                Value<int> repCount = const Value.absent(),
                Value<double> avgVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<double> rom = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> pathDataJson = const Value.absent(),
              }) => SessionSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                setNumber: setNumber,
                repCount: repCount,
                avgVelocity: avgVelocity,
                peakVelocity: peakVelocity,
                rom: rom,
                startedAt: startedAt,
                endedAt: endedAt,
                pathDataJson: pathDataJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionSetsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SessionSetsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSetsTable,
      SessionSet,
      $$SessionSetsTableFilterComposer,
      $$SessionSetsTableOrderingComposer,
      $$SessionSetsTableAnnotationComposer,
      $$SessionSetsTableCreateCompanionBuilder,
      $$SessionSetsTableUpdateCompanionBuilder,
      (SessionSet, $$SessionSetsTableReferences),
      SessionSet,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionSetsTableTableManager get sessionSets =>
      $$SessionSetsTableTableManager(_db, _db.sessionSets);
}
