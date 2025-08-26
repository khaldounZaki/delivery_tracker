import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../data/sn_parser.dart';
import '../data/db.dart';
import '../models/delivery.dart';

class AddDeliveryPage extends StatefulWidget {
  const AddDeliveryPage({super.key});

  @override
  State<AddDeliveryPage> createState() => _AddDeliveryPageState();
}

class _AddDeliveryPageState extends State<AddDeliveryPage> {
  final _snC = TextEditingController();
  final _clientNameC = TextEditingController();
  final _clientPhoneC = TextEditingController();
  final _clientAddressC = TextEditingController();
  final _deliveredByC = TextEditingController(text: 'admin'); // demo
  String _productType = 'Unknown Product';
  bool _saving = false;
  String? _msg;

  void _onSNChanged() {
    setState(() => _productType = productTypeFromSN(_snC.text.trim()));
  }

  @override
  void initState() {
    super.initState();
    _snC.addListener(_onSNChanged);
  }

  @override
  void dispose() {
    _snC.removeListener(_onSNChanged);
    _snC.dispose();
    _clientNameC.dispose();
    _clientPhoneC.dispose();
    _clientAddressC.dispose();
    _deliveredByC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sn = _snC.text.trim();
    if (sn.isEmpty) { setState(() => _msg = 'Serial Number is required'); return; }
    if (_clientNameC.text.trim().isEmpty) { setState(() => _msg = 'Client name is required'); return; }
    if (_clientPhoneC.text.trim().isEmpty) { setState(() => _msg = 'Client phone is required'); return; }

    setState(() { _saving = true; _msg = null; });
    final d = Delivery(
      sn: sn,
      productType: _productType,
      clientName: _clientNameC.text.trim(),
      clientPhone: _clientPhoneC.text.trim(),
      clientAddress: _clientAddressC.text.trim(),
      deliveredBy: _deliveredByC.text.trim(),
      deliveredAt: DateTime.now(),
    );
    try {
      await AppDb.instance.insertDelivery(d);
      if (!mounted) return;
      setState(() {
        _msg = 'Saved!';
        _snC.clear();
        _clientNameC.clear();
        _clientPhoneC.clear();
        _clientAddressC.clear();
        _deliveredByC.text = 'admin';
        _productType = 'Unknown Product';
      });
    } catch (e) {
      setState(() { _msg = 'Error: $e'; });
    } finally {
      setState(() { _saving = false; });
    }
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _ScanPage()),
    );
    if (code != null && code.isNotEmpty) {
      _snC.text = code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Add Delivery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _snC,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number (SN)',
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(onPressed: _scan, icon: const Icon(Icons.camera_alt)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Product: '),
                Chip(label: Text(_productType)),
                const Spacer(),
                Text(fmt.format(DateTime.now())),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clientNameC,
              decoration: const InputDecoration(labelText: 'Client Name', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientPhoneC,
              decoration: const InputDecoration(labelText: 'Client Phone', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientAddressC,
              decoration: const InputDecoration(labelText: 'Client Address', prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deliveredByC,
              decoration: const InputDecoration(labelText: 'Delivered By', prefixIcon: Icon(Icons.badge)),
            ),
            const SizedBox(height: 16),
            if (_msg != null) Text(_msg!, style: TextStyle(color: _msg == 'Saved!' ? Colors.green : Colors.red)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanPage extends StatefulWidget {
  const _ScanPage();

  @override
  State<_ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<_ScanPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan SN')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_handled) return;
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            _handled = true;
            final code = barcodes.first.rawValue ?? '';
            Navigator.of(context).pop(code);
          }
        },
      ),
    );
  }
}
