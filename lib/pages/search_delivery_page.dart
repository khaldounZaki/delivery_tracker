import 'package:flutter/material.dart';
import '../data/db.dart';
import '../models/delivery.dart';

class SearchDeliveryPage extends StatefulWidget {
  const SearchDeliveryPage({super.key});

  @override
  State<SearchDeliveryPage> createState() => _SearchDeliveryPageState();
}

class _SearchDeliveryPageState extends State<SearchDeliveryPage> {
  final _searchC = TextEditingController();
  List<Delivery> results = [];

  void _search() async {
    final query = _searchC.text.trim();
    final deliveries = await DBHelper.searchDeliveries(query);
    setState(() => results = deliveries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
            controller: _searchC,
            decoration: InputDecoration(
              labelText: 'Search (client, phone, note)',
              suffixIcon: IconButton(
                  icon: const Icon(Icons.search), onPressed: _search),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final d = results[i];
                return Card(
                  child: ExpansionTile(
                    title: Text(d.client),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.phone),
                        Text('Delivery Date: ${d.date.split('T')[0]}')
                      ],
                    ),
                    children: d.products
                        .map((p) => ListTile(
                              title: Text(p.description),
                              subtitle: Text(p.sn),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
