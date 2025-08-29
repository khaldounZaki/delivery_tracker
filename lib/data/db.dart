import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery.dart';
import '../models/product.dart';

class DBHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// -----------------------------
  /// Add Delivery + Products
  /// -----------------------------
  static Future<String> insertDelivery(Delivery delivery) async {
    // 1️⃣ Add delivery document
    final docRef = await _db.collection('deliveries').add({
      'client': delivery.client,
      'phone': delivery.phone,
      'note': delivery.note,
      'date': delivery.date,
    });

    // 2️⃣ Add products under this delivery
    final batch = _db.batch(); // optional: use batch for multiple products
    for (var product in delivery.products) {
      final productRef = docRef.collection('products').doc(); // generate doc id
      batch.set(productRef, {
        'sn': product.sn,
        'description': product.description,
      });
    }

    await batch.commit(); // commit all products at once
    return docRef.id;
  }

  /// -----------------------------
  /// Search deliveries (contains-based)
  /// -----------------------------
  static Future<List<Delivery>> searchDeliveries(String query) async {
    // Firestore doesn't support OR directly; we'll search 'client' only as demo
    final snapshot = await _db
        .collection('deliveries')
        .where('client', isGreaterThanOrEqualTo: query)
        .where('client', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<Delivery> deliveries = [];

    for (var doc in snapshot.docs) {
      // Get products subcollection
      final productsSnap = await doc.reference.collection('products').get();
      List<Product> products = productsSnap.docs
          .map((p) => Product.fromMap({...p.data(), 'id': p.id}))
          .toList();

      deliveries.add(Delivery.fromMap({...doc.data(), 'id': doc.id}, products));
    }

    return deliveries;
  }

  /// -----------------------------
  /// Search SN (product only)
  /// -----------------------------
  static Future<Product?> searchSN(String sn) async {
    final snapshot = await _db
        .collectionGroup('products') // search all products across deliveries
        .where('sn', isEqualTo: sn)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return Product.fromMap(
        {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
  }

  /// -----------------------------
  /// Search SN + delivery details
  /// -----------------------------
  static Future<Map<String, dynamic>?> searchSNWithDelivery(String sn) async {
    final snapshot = await _db
        .collectionGroup('products')
        .where('sn', isEqualTo: sn)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final productDoc = snapshot.docs.first;
    final deliveryRef =
        productDoc.reference.parent.parent; // parent delivery document
    final deliverySnap = await deliveryRef!.get();

    final deliveryData = deliverySnap.data() as Map<String, dynamic>;
    final productData = productDoc.data();

    return {
      'sn': productData['sn'],
      'description': productData['description'],
      'client': deliveryData['client'],
      'phone': deliveryData['phone'],
      'note': deliveryData['note'],
      'date': deliveryData['date'],
      'deliveryId': deliveryRef.id,
    };
  }
}

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import '../models/delivery.dart';
// import '../models/product.dart';

// class DBHelper {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   static Future<Database> initDB() async {
//     final path = join(await getDatabasesPath(), 'delivery_tracker.db');
//     return await openDatabase(path, version: 1, onCreate: (db, version) async {
//       await db.execute('''
//         CREATE TABLE deliveries(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           client TEXT,
//           phone TEXT,
//           note TEXT,
//           date TEXT
//         )
//       ''');
//       await db.execute('''
//         CREATE TABLE products(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           deliveryId INTEGER,
//           sn TEXT,
//           description TEXT,
//           FOREIGN KEY(deliveryId) REFERENCES deliveries(id)
//         )
//       ''');
//     });
//   }

//   // Add Delivery + Products
//   static Future<int> insertDelivery(Delivery delivery) async {
//     final db = await database;
//     int deliveryId = await db.insert('deliveries', delivery.toMap());
//     for (var product in delivery.products) {
//       product.deliveryId = deliveryId;
//       await db.insert('products', product.toMap());
//     }
//     return deliveryId;
//   }

//   // Search deliveries (contains-based)
//   static Future<List<Delivery>> searchDeliveries(String query) async {
//     final db = await database;
//     final deliveryMaps = await db.query(
//       'deliveries',
//       where: "client LIKE ? OR phone LIKE ? OR note LIKE ?",
//       whereArgs: ['%$query%', '%$query%', '%$query%'],
//     );

//     List<Delivery> deliveries = [];
//     for (var d in deliveryMaps) {
//       final productsMaps = await db
//           .query('products', where: "deliveryId = ?", whereArgs: [d['id']]);
//       List<Product> products =
//           productsMaps.map((p) => Product.fromMap(p)).toList();
//       deliveries.add(Delivery.fromMap(d, products));
//     }
//     return deliveries;
//   }

//   // Search SN
//   static Future<Product?> searchSN(String sn) async {
//     final db = await database;
//     final maps = await db.query('products', where: "sn = ?", whereArgs: [sn]);
//     if (maps.isEmpty) return null;
//     return Product.fromMap(maps.first);
//   }

//   static Future<Map<String, dynamic>?> searchSNWithDelivery(String sn) async {
//     final db = await database;
//     final result = await db.rawQuery('''
//     SELECT p.sn, p.description, d.client, d.phone, d.note, d.date , d.id as deliveryId
//     FROM products p
//     JOIN deliveries d ON p.deliveryId = d.id
//     WHERE p.sn = ?
//   ''', [sn]);

//     if (result.isEmpty) return null;
//     return result.first;
//   }
// }
