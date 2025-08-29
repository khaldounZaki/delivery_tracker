import 'package:flutter/material.dart';
import '../data/db.dart';
import '../models/product.dart';

class SearchSNPage extends StatefulWidget {
  const SearchSNPage({super.key});

  @override
  State<SearchSNPage> createState() => _SearchSNPageState();
}

class _SearchSNPageState extends State<SearchSNPage> {
  final _snC = TextEditingController();
  Map<String, dynamic>? resultData;

  void _search() async {
    final sn = _snC.text.trim();
    final data = await DBHelper.searchSNWithDelivery(sn);
    setState(() => resultData = data); // resultData is a Map<String, dynamic>?
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search SN')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
            controller: _snC,
            decoration: InputDecoration(
              labelText: 'Enter SN',
              suffixIcon: IconButton(
                  icon: const Icon(Icons.search), onPressed: _search),
            ),
            onSubmitted: (_) => _search(),
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
                    Text('Delivery Date: ${resultData!['date'].split('T')[0]}')
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
