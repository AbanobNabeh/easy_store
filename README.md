# easy_store 

<p align="center">
  <img src="https://img.shields.io/badge/pub-v0.0.1-blue" alt="pub version" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license" />
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20macOS-lightgrey" alt="platform" />
</p>

A simple Flutter storage SDK. One unified API for both **SharedPreferences** and **SQLite** — no boilerplate, no complexity.
https://pub.dev/packages/easy_store

---

## Features

- ✅ SharedPreferences wrapper with type-safe `save` / `get`
- ✅ SQLite wrapper — create tables, insert, update, delete, query
- ✅ Multiple databases support via `EasyStore.createDatabase()`
- ✅ Single `EasyStore.init()` to set everything up
- ✅ No raw SQL needed for common operations
- ✅ Escape hatch via `rawQuery()` for advanced use cases

---

## Installation

```yaml
dependencies:
  easy_store: ^0.0.1
```

---

## Setup

Call `EasyStore.init()` once in `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyStore.init();
  runApp(MyApp());
}
```

---

## SharedPreferences

```dart
// Save
await EasyStore.shared.save("name", "Abanob");
await EasyStore.shared.save("age", 22);
await EasyStore.shared.save("isDark", true);
await EasyStore.shared.save("balance", 99.5);

// Get
String name    = EasyStore.shared.get<String>("name") ?? "Guest";
int    age     = EasyStore.shared.get<int>("age") ?? 0;
bool   isDark  = EasyStore.shared.get<bool>("isDark") ?? false;
double balance = EasyStore.shared.get<double>("balance") ?? 0.0;

// Check existence
bool exists = EasyStore.shared.has("name");

// Delete one key
await EasyStore.shared.delete("name");

// Clear all
await EasyStore.shared.clear();

// Get all keys
Set<String> keys = EasyStore.shared.keys;
```

---

## SQLite

### Default database

```dart
await EasyStore.init(); // creates easy_store.db by default
```

### Custom database name

```dart
await EasyStore.init(dbName: 'my_app.db');
```

### Multiple databases

```dart
final usersDb    = await EasyStore.createDatabase('users.db');
final productsDb = await EasyStore.createDatabase('products.db');

await usersDb.createTable('users', {'name': ColumnType.text});
await productsDb.createTable('products', {'title': ColumnType.text});
```

### Create a table

```dart
await EasyStore.db.createTable("users", {
  "name": ColumnType.text,
  "age": ColumnType.integer,
  "balance": ColumnType.real,
});
// `id` column is added automatically (INTEGER PRIMARY KEY AUTOINCREMENT)
```

### Insert

```dart
int id = await EasyStore.db.insert("users", {
  "name": "Abanob",
  "age": 22,
  "balance": 500.0,
});
```

### Get (Query)

```dart
// All rows
List<Map<String, dynamic>> users = await EasyStore.db.get("users");

// With filter
List<Map<String, dynamic>> adults = await EasyStore.db.get(
  "users",
  where: "age >= 18",
  orderBy: "name ASC",
  limit: 10,
);

// By ID
Map<String, dynamic>? user = await EasyStore.db.getById("users", 1);
```

### Update

```dart
// By condition
await EasyStore.db.update("users", {"age": 23}, where: "name = 'Abanob'");

// By ID
await EasyStore.db.updateById("users", 1, {"age": 23});
```

### Delete

```dart
// By condition
await EasyStore.db.delete("users", where: "age < 18");

// By ID
await EasyStore.db.deleteById("users", 1);

// Clear all rows (keep table)
await EasyStore.db.clearTable("users");

// Drop table
await EasyStore.db.dropTable("users");
```

### Count

```dart
int total  = await EasyStore.db.count("users");
int adults = await EasyStore.db.count("users", where: "age >= 18");
```

### Raw Query (advanced)

```dart
List<Map<String, dynamic>> result = await EasyStore.db.rawQuery(
  "SELECT * FROM users WHERE age BETWEEN 18 AND 30 ORDER BY name",
);
```

---

## ColumnType

| Value                | SQLite type | Dart type  |
|----------------------|-------------|------------|
| `ColumnType.text`    | TEXT        | String     |
| `ColumnType.integer` | INTEGER     | int / bool |
| `ColumnType.real`    | REAL        | double     |
| `ColumnType.blob`    | BLOB        | Uint8List  |

---

## Author

**Abanob Nabeh**

[![GitHub](https://img.shields.io/badge/GitHub-AbanobNabeh-181717?logo=github&logoColor=white)](https://github.com/AbanobNabeh)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-abanobnabeh-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/abanobnabeh/)
[![Instagram](https://img.shields.io/badge/Instagram-abanobnabeeh-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/abanobnabeeh/)

---

## License

MIT © 2026 Abanob Nabeh
