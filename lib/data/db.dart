import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/delivery.dart';
import '../models/product.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'delivery_tracker.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE deliveries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client TEXT,
          phone TEXT,
          note TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deliveryId INTEGER,
          sn TEXT,
          description TEXT,
          FOREIGN KEY(deliveryId) REFERENCES deliveries(id)
        )
      ''');
    });
  }

  // Add Delivery + Products
  static Future<int> insertDelivery(Delivery delivery) async {
    final db = await database;
    int deliveryId = await db.insert('deliveries', delivery.toMap());
    for (var product in delivery.products) {
      product.deliveryId = deliveryId;
      await db.insert('products', product.toMap());
    }
    return deliveryId;
  }

  // Search deliveries (contains-based)
  static Future<List<Delivery>> searchDeliveries(String query) async {
    final db = await database;
    final deliveryMaps = await db.query(
      'deliveries',
      where: "client LIKE ? OR phone LIKE ? OR note LIKE ?",
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    List<Delivery> deliveries = [];
    for (var d in deliveryMaps) {
      final productsMaps = await db
          .query('products', where: "deliveryId = ?", whereArgs: [d['id']]);
      List<Product> products =
          productsMaps.map((p) => Product.fromMap(p)).toList();
      deliveries.add(Delivery.fromMap(d, products));
    }
    return deliveries;
  }

  // Search SN
  static Future<Product?> searchSN(String sn) async {
    final db = await database;
    final maps = await db.query('products', where: "sn = ?", whereArgs: [sn]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }
}
