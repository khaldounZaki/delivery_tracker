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
  Product? result;

  void _search() async {
    final sn = _snC.text.trim();
    final product = await DBHelper.searchSN(sn);
    setState(() => result = product);
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
          if (result != null)
            Card(
              child: ListTile(
                title: Text(result!.description),
                subtitle: Text(
                    'SN: ${result!.sn}\nDelivery ID: ${result!.deliveryId}'),
              ),
            ),
        ]),
      ),
    );
  }
}
