import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:kitoapp/shared/models/compassion_id.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await instance._open();
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    return _open();
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'kgc_connect.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE compassion_ids (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id TEXT NOT NULL UNIQUE,
            student_name TEXT,
            is_assigned INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await _seedCompassionIds(db);
      },
    );

    return _db!;
  }

  Future<void> _seedCompassionIds(Database db) async {
    const ids = [
      'KGC-COMP-001',
      'KGC-COMP-002',
      'KGC-COMP-003',
      'KGC-COMP-004',
      'KGC-COMP-005',
      'KGC-COMP-006',
      'KGC-COMP-007',
      'KGC-COMP-008',
    ];

    final batch = db.batch();
    for (final projectId in ids) {
      batch.insert('compassion_ids', {
        'project_id': projectId,
        'is_assigned': 0,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<CompassionId>> getAvailableCompassionIds() async {
    final db = await database;
    final rows = await db.query(
      'compassion_ids',
      where: 'is_assigned = ?',
      whereArgs: [0],
      orderBy: 'project_id ASC',
    );
    return rows.map(CompassionId.fromMap).toList();
  }

  Future<void> markCompassionIdAssigned(int id) async {
    final db = await database;
    await db.update(
      'compassion_ids',
      {'is_assigned': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
