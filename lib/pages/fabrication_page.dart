import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/sn_parser.dart';

class FabricationPage extends StatefulWidget {
  const FabricationPage({super.key});

  @override
  State<FabricationPage> createState() => _FabricationPageState();
}

class _FabricationPageState extends State<FabricationPage> {
  final _snC = TextEditingController();
  final _noteC = TextEditingController();
  bool _loading = false;

  Future<void> _registerSN(String sn) async {
    if (sn.isEmpty) return;

    final desc = productTypeFromSN(sn);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('fabrications')
          .where('sn', isEqualTo: sn)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SN already registered!')),
        );
      } else {
        await FirebaseFirestore.instance.collection('fabrications').add({
          'sn': sn,
          'description': desc,
          'date': DateTime.now().toIso8601String(),
          'note': _noteC.text,
          'userEmail': user.email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fabrication registered!')),
        );
        _snC.clear();
        _noteC.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _loading = false);
  }

  void _scanSN() async {
    final sn = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );
    if (sn != null) _registerSN(sn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fabrication Done')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _snC,
              decoration: const InputDecoration(labelText: 'Product SN'),
            ),
            TextField(
              controller: _noteC,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : () => _registerSN(_snC.text),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _scanSN,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan SN'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPage extends StatelessWidget {
  const _ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan SN')),
      body: MobileScanner(
        onDetect: (capture) {
          final sn = capture.barcodes.first.rawValue;
          if (sn != null) Navigator.of(context).pop(sn);
        },
      ),
    );
  }
}
