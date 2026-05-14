/// Defines the data type of a SQLite table column.
///
/// Used when creating tables with [EasyDb.createTable].
///
/// ```dart
/// await EasyStore.db.createTable("users", {
///   "id": ColumnType.integer,
///   "name": ColumnType.text,
///   "balance": ColumnType.real,
///   "avatar": ColumnType.blob,
/// });
/// ```
enum ColumnType {
  /// Integer column (int, bool).
  integer,

  /// Text column (String).
  text,

  /// Real column (double, float).
  real,

  /// Blob column (binary data, Uint8List).
  blob,
}

/// Extension to convert [ColumnType] to its SQLite string representation.
extension ColumnTypeExtension on ColumnType {
  /// Returns the SQLite type name for this column type.
  String get sql {
    switch (this) {
      case ColumnType.integer:
        return 'INTEGER';
      case ColumnType.text:
        return 'TEXT';
      case ColumnType.real:
        return 'REAL';
      case ColumnType.blob:
        return 'BLOB';
    }
  }
}
