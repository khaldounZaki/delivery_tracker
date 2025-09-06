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
  String? _description; // ✅ store description after scan

  Future<void> _registerSN(String sn) async {
    if (sn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan an SN before registering.')),
      );
      return;
    }

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
        setState(() => _description = null); // reset description
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _loading = false);
  }

  /// Scan dialog (inline with SN field)
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
              final sn = capture.barcodes.first.rawValue;
              if (sn != null) {
                Navigator.pop(context); // close scanner
                setState(() {
                  _snC.text = sn; // ✅ fill SN from scan only
                  _description = productTypeFromSN(sn); // ✅ update desc
                });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fabrication Done')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _snC,
                    readOnly: true, // 🚫 user cannot type
                    decoration: const InputDecoration(labelText: 'Product SN'),
                  ),
                ),
                IconButton(
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner, size: 30),
                  tooltip: "Scan SN",
                ),
              ],
            ),
            if (_description != null) ...[
              const SizedBox(height: 8),
              Text(
                "Description: $_description",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteC,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _registerSN(_snC.text),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
