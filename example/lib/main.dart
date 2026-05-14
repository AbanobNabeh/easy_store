import 'package:flutter/material.dart';
import 'package:easy_store/easy_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyStore.init(dbName: 'my_app.db');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'EasyStore Demo', home: const ExamplePage());
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});
  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // ── Shared Preferences controllers ──
  final _spKeyCtrl = TextEditingController();
  final _spValCtrl = TextEditingController();
  final _spGetKeyCtrl = TextEditingController();
  String _spType = 'String';
  String _spLog = '// output appears here';

  final _dbNameCtrl = TextEditingController(text: 'my_app.db');
  final _tblNameCtrl = TextEditingController(text: 'users');
  final _tblColsCtrl = TextEditingController(text: 'name:text, age:integer');
  final _insTblCtrl = TextEditingController(text: 'users');
  final _insDataCtrl = TextEditingController(text: 'name:Abanob, age:22');
  final _updTblCtrl = TextEditingController(text: 'users');
  final _updDataCtrl = TextEditingController(text: 'age:23');
  final _updIdCtrl = TextEditingController(text: '1');
  final _delTblCtrl = TextEditingController(text: 'users');
  final _delIdCtrl = TextEditingController(text: '1');
  String _dbLog = '// output appears here';
  List<Map<String, dynamic>> _rows = [];

  Future<void> _spSave() async {
    final key = _spKeyCtrl.text.trim();
    final val = _spValCtrl.text.trim();
    if (key.isEmpty || val.isEmpty) {
      setState(() => _spLog = '// key and value required');
      return;
    }
    try {
      switch (_spType) {
        case 'int':
          await EasyStore.shared.save(key, int.parse(val));
        case 'double':
          await EasyStore.shared.save(key, double.parse(val));
        case 'bool':
          await EasyStore.shared.save(key, val == 'true');
        default:
          await EasyStore.shared.save(key, val);
      }
      setState(() => _spLog = '✓ saved  "$key" = $val  ($_spType)');
    } catch (e) {
      setState(() => _spLog = '// error: $e');
    }
  }

  void _spGet() {
    final key = _spGetKeyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _spLog = '// enter a key to get');
      return;
    }
    final value = EasyStore.shared.get(key);
    setState(
      () =>
          _spLog =
              value != null
                  ? '✓ get("$key")  →  $value'
                  : '// key "$key" not found',
    );
  }

  Future<void> _spDelete() async {
    final key = _spGetKeyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _spLog = '// enter a key to delete');
      return;
    }
    await EasyStore.shared.delete(key);
    setState(() => _spLog = '✓ deleted  "$key"');
  }

  Future<void> _spClear() async {
    await EasyStore.shared.clear();
    setState(() => _spLog = '✓ cleared all keys');
  }

  // ─────────────────────────────────────────────
  // SQLite helpers
  // ─────────────────────────────────────────────

  Map<String, dynamic> _parseKV(String input) {
    final map = <String, dynamic>{};
    for (final pair in input.split(',')) {
      final parts = pair.trim().split(':');
      if (parts.length == 2) {
        final k = parts[0].trim();
        final v = parts[1].trim();
        map[k] = num.tryParse(v) ?? v;
      }
    }
    return map;
  }

  Map<String, ColumnType> _parseCols(String input) {
    final map = <String, ColumnType>{};
    for (final pair in input.split(',')) {
      final parts = pair.trim().split(':');
      if (parts.length == 2) {
        final name = parts[0].trim();
        final type = switch (parts[1].trim().toLowerCase()) {
          'integer' => ColumnType.integer,
          'real' => ColumnType.real,
          'blob' => ColumnType.blob,
          _ => ColumnType.text,
        };
        map[name] = type;
      }
    }
    return map;
  }

  void _appendDbLog(String msg) => setState(
    () => _dbLog = _dbLog == '// output appears here' ? msg : '$_dbLog\n$msg',
  );

  Future<void> _refreshRows(String table) async {
    try {
      final rows = await EasyStore.db.get(table);
      setState(() => _rows = rows);
    } catch (_) {
      setState(() => _rows = []);
    }
  }

  // ─────────────────────────────────────────────
  // SQLite operations
  // ─────────────────────────────────────────────

  Future<void> _createTable() async {
    final tbl = _tblNameCtrl.text.trim();
    final cols = _parseCols(_tblColsCtrl.text);
    try {
      await EasyStore.db.createTable(tbl, cols);
      _appendDbLog('✓ createTable("$tbl")');
      await _refreshRows(tbl);
    } catch (e) {
      _appendDbLog('// error: $e');
    }
  }

  Future<void> _insertRow() async {
    final tbl = _insTblCtrl.text.trim();
    final data = _parseKV(_insDataCtrl.text);
    try {
      final id = await EasyStore.db.insert(tbl, data);
      _appendDbLog('✓ insert → id: $id');
      await _refreshRows(tbl);
    } catch (e) {
      _appendDbLog('// error: $e');
    }
  }

  Future<void> _updateRow() async {
    final tbl = _updTblCtrl.text.trim();
    final data = _parseKV(_updDataCtrl.text);
    final id = int.tryParse(_updIdCtrl.text) ?? 0;
    try {
      await EasyStore.db.updateById(tbl, id, data);
      _appendDbLog('✓ updateById("$tbl", $id)');
      await _refreshRows(tbl);
    } catch (e) {
      _appendDbLog('// error: $e');
    }
  }

  Future<void> _deleteRow() async {
    final tbl = _delTblCtrl.text.trim();
    final id = int.tryParse(_delIdCtrl.text) ?? 0;
    try {
      await EasyStore.db.deleteById(tbl, id);
      _appendDbLog('✓ deleteById("$tbl", $id)');
      await _refreshRows(tbl);
    } catch (e) {
      _appendDbLog('// error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // UI helpers
  // ─────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.grey,
      ),
    ),
  );

  Widget _logBox(String log) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      log,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    ),
  );

  Widget _card({
    required String title,
    required String badge,
    required Color badgeColor,
    required Widget child,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('EasyStore Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shared Preferences Card ──────────────────
            _card(
              title: 'Shared Preferences',
              badge: 'EasyStore.shared',
              badgeColor: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('SAVE'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _spKeyCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _spValCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _spType,
                        isDense: true,
                        items:
                            ['String', 'int', 'double', 'bool']
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _spType = v!),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _spSave,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _sectionLabel('GET / DELETE'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _spGetKeyCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _spGet,
                        child: const Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _spDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _spClear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _logBox(_spLog),
                ],
              ),
            ),

            // ── SQLite Card ──────────────────────────────
            _card(
              title: 'SQLite',
              badge: 'EasyStore.db',
              badgeColor: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create Table
                  _sectionLabel('CREATE TABLE'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tblNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Table name',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _tblColsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Columns (name:type, ...)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _createTable,
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Insert
                  _sectionLabel('INSERT'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _insTblCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Table',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _insDataCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Data (key:value, ...)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _insertRow,
                        child: const Text('Insert'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Update
                  _sectionLabel('UPDATE'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _updTblCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Table',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _updDataCtrl,
                          decoration: const InputDecoration(
                            labelText: 'New data (key:value, ...)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _updIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ID',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _updateRow,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Delete
                  _sectionLabel('DELETE'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _delTblCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Table',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _delIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ID',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _deleteRow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Results table
                  _sectionLabel('RESULTS'),
                  if (_rows.isEmpty)
                    const Text(
                      'No data yet — insert some rows',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 36,
                        dataRowMinHeight: 32,
                        dataRowMaxHeight: 40,
                        columns:
                            _rows.first.keys
                                .map(
                                  (k) => DataColumn(
                                    label: Text(
                                      k,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        rows:
                            _rows
                                .map(
                                  (row) => DataRow(
                                    cells:
                                        row.values
                                            .map(
                                              (v) => DataCell(
                                                Text(
                                                  '$v',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _logBox(_dbLog),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
