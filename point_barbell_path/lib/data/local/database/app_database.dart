import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get exerciseType => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalReps => integer().withDefault(const Constant(0))();
  IntColumn get totalSets => integer().withDefault(const Constant(0))();
  RealColumn get avgVelocity => real().withDefault(const Constant(0.0))();
  RealColumn get peakVelocity => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get videoPath => text().nullable()();
}

class SessionSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get setNumber => integer()();
  IntColumn get repCount => integer().withDefault(const Constant(0))();
  RealColumn get avgVelocity => real().withDefault(const Constant(0.0))();
  RealColumn get peakVelocity => real().withDefault(const Constant(0.0))();
  RealColumn get rom => real().withDefault(const Constant(0.0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get pathDataJson => text().withDefault(const Constant(''))();
}

@DriftDatabase(tables: [Sessions, SessionSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'point_barbell_path.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // Session queries
  Future<List<Session>> getAllSessions() =>
      (select(sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();

  Future<Session?> getSession(int id) =>
      (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Session?> getSessionByUuid(String uuid) =>
      (select(sessions)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<bool> updateSession(SessionsCompanion session) =>
      update(sessions).replace(session);

  Future<int> deleteSession(int id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();

  // Set queries
  Future<List<SessionSet>> getSetsForSession(int sessionId) =>
      (select(sessionSets)..where((t) => t.sessionId.equals(sessionId))).get();

  Future<int> insertSet(SessionSetsCompanion set_) =>
      into(sessionSets).insert(set_);

  Stream<List<Session>> watchAllSessions() =>
      (select(sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).watch();
}
