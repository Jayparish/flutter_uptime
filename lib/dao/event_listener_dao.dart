import 'package:drift/drift.dart' as drift;
import '../constants/common_constants.dart';
import '../drift_db/database.dart';

class EventListenerDao {
  AppDatabase database = AppDatabase();

  Future<int?> insertEvents(
      List<EventListenerCompanion> eventListenerCompanion) async {
    if (eventListenerCompanion.isNotEmpty) {
      try {
        database.batch((batch) {
          return batch.insertAllOnConflictUpdate(
              database.eventListener, eventListenerCompanion);
        });
      } catch (e, s) {
        showLog("the error in album insert $e,$s");
      }
    }
  }

  Future<List<EventListenerData>> getEvents() async {
    return await (database.select(database.eventListener)).get();
  }

  Stream<List<EventListenerData>> watchEvents() {
    return (database.select(database.eventListener)).watch();
  }

  Future<List<EventListenerData>> getEventsWhereNotSynced() async {
    return await (database.select(database.eventListener)
          ..where((tbl) => tbl.live.equals(false)))
        .get();
  }

  Future<List<EventListenerData>> getEventsLimit() async {
    return await (database.select(database.eventListener)
          ..orderBy([
            (t) => drift.OrderingTerm.desc(t.id)
            // Adjust 'id' to your primary key column name
          ])
          ..limit(2))
        .get();
  }

  updateStatusTrue({
    required String url,
  }) async {
    showLog('updateStatus $url ,');
    await (database.update(database.eventListener)
          ..where((tbl) => tbl.websiteURl.equals(url)))
        .write(const EventListenerCompanion(
      live: drift.Value(true),
    ));
  }
 updateAlarmStatusFalse({
    required String url,
  }) async {
    showLog('updateStatus $url ,');
    await (database.update(database.eventListener)
          ..where((tbl) => tbl.websiteURl.equals(url)))
        .write(const EventListenerCompanion(
      inTime: drift.Value('2'),
    ));
  }updateAlarmStatusTrue({
    required String url,
  }) async {
    showLog('updateStatus $url ,');
    await (database.update(database.eventListener)
          ..where((tbl) => tbl.websiteURl.equals(url)))
        .write(const EventListenerCompanion(
      inTime: drift.Value('1'),
    ));
  }

  updateStatusFalse({
    required String url,
  }) async {
    showLog('updateStatus $url ,');
    await (database.update(database.eventListener)
          ..where((tbl) => tbl.websiteURl.equals(url)))
        .write(const EventListenerCompanion(
      live: drift.Value(false),
    ));
  }

  Future<void> deleteEventListenerTable() async {
    await (database.delete(database.eventListener)).go();
  }

  deleteEventListenerBYUrl({required String url}) async {
    await (database.delete(database.eventListener)
          ..where((tbl) => tbl.websiteURl.equals(url)))
        .go();
  }
}
