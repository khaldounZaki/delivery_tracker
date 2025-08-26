import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/delivery.dart';

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'delivery_tracker.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE deliveries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sn TEXT UNIQUE NOT NULL,
            product_type TEXT NOT NULL,
            client_name TEXT NOT NULL,
            client_phone TEXT NOT NULL,
            client_address TEXT NOT NULL,
            delivered_by TEXT NOT NULL,
            delivered_at INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_deliveries_client ON deliveries(client_name, client_phone);
        ''');
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_deliveries_sn ON deliveries(sn);
        ''');
      },
    );
  }

  Future<int> insertDelivery(Delivery d) async {
    final db = await database;
    return await db.insert('deliveries', d.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Delivery?> getBySN(String sn) async {
    final db = await database;
    final rows = await db.query('deliveries', where: 'sn = ?', whereArgs: [sn]);
    if (rows.isEmpty) return null;
    return Delivery.fromMap(rows.first);
  }

  Future<List<Delivery>> searchDeliveries({String? query, DateTime? from, DateTime? to}) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(client_name LIKE ? OR client_phone LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }
    if (from != null) {
      where.add('delivered_at >= ?');
      args.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where.add('delivered_at <= ?');
      args.add(to.millisecondsSinceEpoch);
    }

    final rows = await db.query(
      'deliveries',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'delivered_at DESC',
    );
    return rows.map((e) => Delivery.fromMap(e)).toList();
  }
}
