import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/db.dart';

class SearchSNPage extends StatefulWidget {
  const SearchSNPage({super.key});

  @override
  State<SearchSNPage> createState() => _SearchSNPageState();
}

class _SearchSNPageState extends State<SearchSNPage> {
  final _snC = TextEditingController();
  Map<String, dynamic>? resultData;
  bool isScanning = false;

  void _search([String? snValue]) async {
    final sn = (snValue ?? _snC.text).trim();
    if (sn.isEmpty) return;
    final data = await DBHelper.searchSNWithDelivery(sn);
    setState(() => resultData = data);
  }

  void _startScanner() {
    setState(() => isScanning = true);
  }

  void _stopScanner() {
    setState(() => isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search SN')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          if (!isScanning) ...[
            TextField(
              controller: _snC,
              decoration: InputDecoration(
                labelText: 'Enter SN',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search), onPressed: _search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan SN"),
              onPressed: _startScanner,
            ),
            const SizedBox(height: 20),
            if (resultData != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(resultData!['description'] ?? 'Unknown Product'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SN: ${resultData!['sn'] ?? ''}'),
                      Text('Client: ${resultData!['client'] ?? ''}'),
                      Text('Phone: ${resultData!['phone'] ?? ''}'),
                      Text('Note: ${resultData!['note'] ?? ''}'),
                      Text(
                        'Delivery Date: ${resultData!['date']?.toString().split('T')[0] ?? ''}',
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (isScanning)
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.first.rawValue;
                  if (barcode != null) {
                    _stopScanner();
                    _snC.text = barcode;
                    _search(barcode);
                  }
                },
              ),
            ),
        ]),
      ),
    );
  }
}
