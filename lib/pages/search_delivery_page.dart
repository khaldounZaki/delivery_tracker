import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/db.dart';
import '../models/delivery.dart';
import '../widgets/delivery_card.dart';

class SearchDeliveryPage extends StatefulWidget {
  const SearchDeliveryPage({super.key});

  @override
  State<SearchDeliveryPage> createState() => _SearchDeliveryPageState();
}

class _SearchDeliveryPageState extends State<SearchDeliveryPage> {
  final _queryC = TextEditingController();
  DateTime? _from;
  DateTime? _to;
  List<Delivery> _results = [];
  bool _loading = false;

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, firstDate: DateTime(now.year - 5), lastDate: DateTime(now.year + 1), initialDate: _from ?? now,
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, firstDate: DateTime(now.year - 5), lastDate: DateTime(now.year + 1), initialDate: _to ?? now,
    );
    if (picked != null) setState(() => _to = picked.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final res = await AppDb.instance.searchDeliveries(
      query: _queryC.text.trim().isEmpty ? null : _queryC.text.trim(),
      from: _from,
      to: _to,
    );
    setState(() { _results = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('Search Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _queryC,
              decoration: const InputDecoration(
                labelText: 'Search by client name or phone',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFrom,
                    icon: const Icon(Icons.date_range),
                    label: Text(_from == null ? 'From Date' : fmt.format(_from!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTo,
                    icon: const Icon(Icons.event),
                    label: Text(_to == null ? 'To Date' : fmt.format(_to!)),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(onPressed: _loading ? null : _search, icon: const Icon(Icons.filter_alt), label: const Text('Apply')),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No results yet. Enter a query and tap Apply.'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) => DeliveryCard(delivery: _results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
