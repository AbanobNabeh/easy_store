/// A simple and elegant Flutter storage solution.
///
/// Provides a unified API for both SharedPreferences and SQLite,
/// making local storage as simple as one line of code.
///
/// ## Quick Start
/// ```dart
/// // Initialize once in main()
/// await EasyStore.init();
///
/// // Shared Preferences
/// await EasyStore.shared.save("name", "Abanob");
/// String name = EasyStore.shared.get("name");
///
/// // SQLite
/// await EasyStore.db.createTable("users", {
///   "id": ColumnType.integer,
///   "name": ColumnType.text,
/// });
/// await EasyStore.db.insert("users", {"name": "Abanob"});
/// ```
library easy_store;

export 'src/easy_shared/easy_shared.dart';
export 'src/database/easy_db.dart';
export 'src/database/column_type.dart';
export 'src/easy_store_main.dart';
