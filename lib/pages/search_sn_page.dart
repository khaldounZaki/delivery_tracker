import 'package:flutter/material.dart';
import '../data/db.dart';
import '../models/delivery.dart';
import '../widgets/delivery_card.dart';

class SearchSNPage extends StatefulWidget {
  const SearchSNPage({super.key});

  @override
  State<SearchSNPage> createState() => _SearchSNPageState();
}

class _SearchSNPageState extends State<SearchSNPage> {
  final _snC = TextEditingController();
  Delivery? _result;
  bool _loading = false;
  String? _msg;

  Future<void> _search() async {
    setState(() { _loading = true; _msg = null; _result = null; });
    final sn = _snC.text.trim();
    if (sn.isEmpty) {
      setState(() { _msg = 'Enter an SN to search'; _loading = false; });
      return;
    }
    final r = await AppDb.instance.getBySN(sn);
    setState(() {
      _result = r;
      _msg = r == null ? 'Not found' : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search SN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _snC,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                prefixIcon: Icon(Icons.qr_code_2),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Expanded(
              child: _result == null
                  ? const SizedBox.shrink()
                  : ListView(children: [DeliveryCard(delivery: _result!)]),
            ),
          ],
        ),
      ),
    );
  }
}
