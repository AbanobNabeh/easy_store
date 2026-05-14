import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'column_type.dart';

/// A simple wrapper around [sqflite] for SQLite database operations.
///
/// Supports creating tables, inserting, updating, deleting, and querying rows
/// without writing raw SQL.
///
/// Do not instantiate directly — use [EasyStore.db] after calling [EasyStore.init].
class EasyDb {
  EasyDb._(this._db);

  final Database _db;

  /// Initializes the SQLite database.
  ///
  /// [dbName] is the filename of the database (e.g., `'my_app.db'`).
  static Future<EasyDb> init({String dbName = 'easy_store.db'}) async {
    final path = join(await getDatabasesPath(), dbName);
    final db = await openDatabase(path, version: 1);
    return EasyDb._(db);
  }

  /// Creates a table if it does not already exist.
  ///
  /// [tableName] is the name of the table.
  /// [columns] is a map of column names to their [ColumnType].
  ///
  /// An `id` column (INTEGER PRIMARY KEY AUTOINCREMENT) is always added automatically.
  ///
  /// ```dart
  /// await EasyStore.db.createTable("users", {
  ///   "name": ColumnType.text,
  ///   "age": ColumnType.integer,
  ///   "balance": ColumnType.real,
  /// });
  /// ```
  Future<void> createTable(
    String tableName,
    Map<String, ColumnType> columns,
  ) async {
    final cols = columns.entries
        .map((e) => '${e.key} ${e.value.sql}')
        .join(', ');

    await _db.execute(
      'CREATE TABLE IF NOT EXISTS $tableName '
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, $cols)',
    );
  }

  /// Drops (deletes) a table if it exists.
  ///
  /// ```dart
  /// await EasyStore.db.dropTable("users");
  /// ```
  Future<void> dropTable(String tableName) async {
    await _db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Inserts a row into [tableName].
  ///
  /// Returns the `id` of the newly inserted row.
  ///
  /// ```dart
  /// int id = await EasyStore.db.insert("users", {
  ///   "name": "Abanob",
  ///   "age": 22,
  /// });
  /// ```
  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    return await _db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves rows from [tableName].
  ///
  /// Optionally filter with [where] (e.g., `"age > 18"`),
  /// limit results with [limit], or order with [orderBy].
  ///
  /// Returns a list of row maps.
  ///
  /// ```dart
  /// // Get all users
  /// List<Map<String, dynamic>> users = await EasyStore.db.get("users");
  ///
  /// // Get filtered
  /// List<Map<String, dynamic>> adults = await EasyStore.db.get(
  ///   "users",
  ///   where: "age >= 18",
  ///   orderBy: "name ASC",
  ///   limit: 10,
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> get(
    String tableName, {
    String? where,
    String? orderBy,
    int? limit,
  }) async {
    return await _db.query(
      tableName,
      where: where,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Retrieves a single row by its [id] from [tableName].
  ///
  /// Returns `null` if no row is found.
  ///
  /// ```dart
  /// Map<String, dynamic>? user = await EasyStore.db.getById("users", 1);
  /// ```
  Future<Map<String, dynamic>?> getById(String tableName, int id) async {
    final result = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Updates rows in [tableName] that match [where].
  ///
  /// Returns the number of rows affected.
  ///
  /// ```dart
  /// int affected = await EasyStore.db.update(
  ///   "users",
  ///   {"age": 23},
  ///   where: "name = 'Abanob'",
  /// );
  /// ```
  Future<int> update(
    String tableName,
    Map<String, dynamic> data, {
    required String where,
  }) async {
    return await _db.update(tableName, data, where: where);
  }

  /// Updates a single row by its [id] in [tableName].
  ///
  /// Returns the number of rows affected (0 or 1).
  ///
  /// ```dart
  /// await EasyStore.db.updateById("users", 1, {"age": 23});
  /// ```
  Future<int> updateById(
    String tableName,
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _db.update(tableName, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes rows from [tableName] that match [where].
  ///
  /// Returns the number of rows deleted.
  ///
  /// ```dart
  /// int deleted = await EasyStore.db.delete("users", where: "age < 18");
  /// ```
  Future<int> delete(String tableName, {required String where}) async {
    return await _db.delete(tableName, where: where);
  }

  /// Deletes a single row by its [id] from [tableName].
  ///
  /// Returns the number of rows deleted (0 or 1).
  ///
  /// ```dart
  /// await EasyStore.db.deleteById("users", 1);
  /// ```
  Future<int> deleteById(String tableName, int id) async {
    return await _db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all rows from [tableName] without dropping the table.
  ///
  /// ```dart
  /// await EasyStore.db.clearTable("users");
  /// ```
  Future<void> clearTable(String tableName) async {
    await _db.delete(tableName);
  }

  /// Returns the number of rows in [tableName].
  ///
  /// Optionally filter with [where].
  ///
  /// ```dart
  /// int count = await EasyStore.db.count("users");
  /// int adults = await EasyStore.db.count("users", where: "age >= 18");
  /// ```
  Future<int> count(String tableName, {String? where}) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM $tableName${where != null ? ' WHERE $where' : ''}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Executes a raw SQL query and returns the results.
  ///
  /// Use this for advanced queries not covered by the standard API.
  ///
  /// ```dart
  /// List<Map<String, dynamic>> result = await EasyStore.db.rawQuery(
  ///   "SELECT * FROM users WHERE age BETWEEN 18 AND 30 ORDER BY name",
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> rawQuery(String sql) async {
    return await _db.rawQuery(sql);
  }

  /// Closes the database connection.
  ///
  /// Call this when the database is no longer needed (e.g., app shutdown).
  Future<void> close() async {
    await _db.close();
  }
}
