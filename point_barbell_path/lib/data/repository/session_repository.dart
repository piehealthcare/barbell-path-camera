import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../local/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

class SessionRepository {
  final AppDatabase _db;
  const SessionRepository(this._db);

  Future<List<Session>> getAllSessions() => _db.getAllSessions();

  Stream<List<Session>> watchAllSessions() => _db.watchAllSessions();

  Future<Session?> getSession(int id) => _db.getSession(id);

  Future<Session?> getSessionByUuid(String uuid) =>
      _db.getSessionByUuid(uuid);

  Future<String> createSession({
    required String exerciseType,
  }) async {
    final uuid = const Uuid().v4();
    final companion = SessionsCompanion.insert(
      uuid: uuid,
      exerciseType: exerciseType,
      startedAt: DateTime.now(),
    );
    await _db.insertSession(companion);
    return uuid;
  }

  Future<void> endSession({
    required String uuid,
    required int totalReps,
    required int totalSets,
    required double avgVelocity,
    required double peakVelocity,
    String? videoPath,
    String notes = '',
  }) async {
    final session = await _db.getSessionByUuid(uuid);
    if (session == null) return;

    await (_db.update(_db.sessions)..where((t) => t.uuid.equals(uuid))).write(
      SessionsCompanion(
        endedAt: Value(DateTime.now()),
        totalReps: Value(totalReps),
        totalSets: Value(totalSets),
        avgVelocity: Value(avgVelocity),
        peakVelocity: Value(peakVelocity),
        videoPath: Value(videoPath),
        notes: Value(notes),
      ),
    );
  }

  Future<void> deleteSession(int id) => _db.deleteSession(id);

  Future<List<SessionSet>> getSetsForSession(int sessionId) =>
      _db.getSetsForSession(sessionId);

  Future<void> addSet({
    required int sessionId,
    required int setNumber,
    required int repCount,
    required double avgVelocity,
    required double peakVelocity,
    required double rom,
    required String pathDataJson,
  }) async {
    await _db.insertSet(SessionSetsCompanion.insert(
      sessionId: sessionId,
      setNumber: setNumber,
      repCount: Value(repCount),
      avgVelocity: Value(avgVelocity),
      peakVelocity: Value(peakVelocity),
      rom: Value(rom),
      startedAt: DateTime.now(),
      pathDataJson: Value(pathDataJson),
    ));
  }
}
