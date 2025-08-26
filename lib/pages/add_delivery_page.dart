import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

  List<Product> products = [];

  void _addProduct(String sn) {
    if (sn.isEmpty) return;
    final desc = productTypeFromSN(sn);
    setState(() {
      products.add(Product(sn: sn, description: desc));
      _snC.clear();
    });
  }

  void _scanSN() async {
    String? scannedSN = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ScannerPage(),
    ));
    if (scannedSN != null) _addProduct(scannedSN);
  }

  Future<void> _saveDelivery() async {
    if (_clientC.text.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client & products required')));
      return;
    }
    final delivery = Delivery(
      client: _clientC.text,
      phone: _phoneC.text,
      note: _noteC.text,
      products: products,
    );
    await DBHelper.insertDelivery(delivery);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
              controller: _clientC,
              decoration: const InputDecoration(labelText: 'Client')),
          TextField(
              controller: _phoneC,
              decoration: const InputDecoration(labelText: 'Phone')),
          TextField(
              controller: _noteC,
              decoration: const InputDecoration(labelText: 'Note')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                  controller: _snC,
                  decoration: const InputDecoration(labelText: 'Product SN')),
            ),
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addProduct(_snC.text)),
            IconButton(
                icon: const Icon(Icons.qr_code_scanner), onPressed: _scanSN),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(products[i].description),
                subtitle: Text(products[i].sn),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => products.removeAt(i)),
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: _saveDelivery, child: const Text('Save Delivery')),
        ]),
      ),
    );
  }
}

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan SN')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final sn = barcodes.first.rawValue;
            if (sn != null) {
              Navigator.of(context).pop(sn);
            }
          }
        },
      ),
    );
  }
}
