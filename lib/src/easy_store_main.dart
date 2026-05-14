import 'easy_shared/easy_shared.dart' show EasyShared;
import 'database/easy_db.dart' show EasyDb;

/// The main entry point for EasyStore.
///
/// Call [EasyStore.init] once in your `main()` before using any storage.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await EasyStore.init();
///   runApp(MyApp());
/// }
/// ```
class EasyStore {
  EasyStore._();

  static EasyShared? _shared;
  static EasyDb? _db;

  /// Initializes both SharedPreferences and SQLite.
  ///
  /// Must be called once before using [shared] or [db].
  /// Typically called in `main()` after [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> init({String dbName = 'easy_store.db'}) async {
    _shared = await EasyShared.init();
    _db = await EasyDb.init(dbName: dbName);
  }

  /// Access to SharedPreferences operations.
  ///
  /// Use for simple key-value storage (String, int, double, bool).
  ///
  /// Throws [StateError] if [init] has not been called yet.
  static EasyShared get shared {
    if (_shared == null) {
      throw StateError(
          'EasyStore not initialized. Call EasyStore.init() first.');
    }
    return _shared!;
  }

  /// Access to SQLite database operations.
  ///
  /// Use for structured/relational data storage.
  ///
  /// Throws [StateError] if [init] has not been called yet.
  static EasyDb get db {
    if (_db == null) {
      throw StateError(
          'EasyStore not initialized. Call EasyStore.init() first.');
    }
    return _db!;
  }
}
