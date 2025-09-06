import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/db.dart';
import '../data/sn_parser.dart';
import '../models/delivery.dart';
import '../models/product.dart';

class AddDeliveryPage extends StatefulWidget {
  const AddDeliveryPage({super.key});
  @override
  State<AddDeliveryPage> createState() => _AddDeliveryPageState();
}

class _AddDeliveryPageState extends State<AddDeliveryPage> {
  final _clientC = TextEditingController();
  final _phoneC = TextEditingController();
  final _noteC = TextEditingController();
  final _snC = TextEditingController();

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Product> products = [];
  List<String> scannedSNs = [];

  /// Play beep + vibrate
  Future<void> _feedback() async {
    await _audioPlayer.play(AssetSource('beep.wav'));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  /// Check if SN already exists in deliveries
  Future<bool> _isSNUsed(String sn) async {
    final snap = await FirebaseFirestore.instance
        .collection('deliveries')
        .where('products', arrayContainsAny: [
      {'sn': sn}
    ]).get();
    return snap.docs.isNotEmpty;
  }

  /// Ensure SN exists in fabrications (if not, add it)
  Future<void> _ensureFabrication(String sn, String desc) async {
    final snap = await FirebaseFirestore.instance
        .collection('fabrications')
        .where('sn', isEqualTo: sn)
        .get();

    if (snap.docs.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('fabrications').add({
        'sn': sn,
        'description': desc,
        'date': DateTime.now().toIso8601String(),
        'note': 'Added from Delivery',
        'user': user?.email ?? 'unknown',
      });
    }
  }

  /// Add product from SN
  Future<void> _addProduct(String sn) async {
    if (sn.isEmpty || scannedSNs.contains(sn)) return;

    // Check duplicates in Firestore
    final used = await _isSNUsed(sn);
    if (used) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SN $sn already exists in deliveries')),
      );
      return;
    }

    final desc = productTypeFromSN(sn);

    // Add to fabrication if missing
    await _ensureFabrication(sn, desc);

    setState(() {
      products.add(Product(sn: sn, description: desc));
      scannedSNs.add(sn);
      _snC.clear();
    });

    _feedback();
  }

  /// Open scanner in a dialog
  void _openScanner() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scan SN'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            onDetect: (capture) async {
              final barcode = capture.barcodes.first;
              final sn = barcode.rawValue;
              if (sn != null && !scannedSNs.contains(sn)) {
                Navigator.pop(context); // close dialog after scan
                await _addProduct(sn);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Save delivery + products to Firebase/DB
  Future<void> _saveDelivery() async {
    if (_clientC.text.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client & products are required')),
      );
      return;
    }

    final delivery = Delivery(
      client: _clientC.text,
      phone: _phoneC.text,
      note: _noteC.text,
      products: products,
    );

    try {
      await DBHelper.insertDelivery(delivery);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Delivery saved!')));
      Navigator.of(context).pop(); // Pop AFTER saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save delivery: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _clientC,
              decoration: const InputDecoration(labelText: 'Client'),
            ),
            TextField(
              controller: _phoneC,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _noteC,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _snC,
                    decoration: const InputDecoration(labelText: 'Product SN'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addProduct(_snC.text),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _openScanner,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    title: Text(products[i].description),
                    subtitle: Text(products[i].sn),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          scannedSNs.remove(products[i].sn);
                          products.removeAt(i);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveDelivery,
              child: const Text('Save Delivery'),
            ),
          ],
        ),
      ),
    );
  }
}
