import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

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

  /// Add product from SN
  void _addProduct(String sn) {
    if (sn.isEmpty || scannedSNs.contains(sn)) return;

    final desc = productTypeFromSN(sn);
    setState(() {
      products.add(Product(sn: sn, description: desc));
      scannedSNs.add(sn);
      _snC.clear();
    });
  }

  /// Play beep + vibrate
  Future<void> _feedback() async {
    // Play a short beep (make sure you add "assets/beep.mp3" in pubspec.yaml)
    await _audioPlayer.play(AssetSource('beep.wav'));

    // Vibrate if device supports it
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200); // short vibration
    }
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
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final sn = barcode.rawValue;
              if (sn != null && !scannedSNs.contains(sn)) {
                setState(() {
                  products
                      .add(Product(sn: sn, description: productTypeFromSN(sn)));
                  scannedSNs.add(sn);
                });
                _feedback(); // 🔊 beep + vibration on scan
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
