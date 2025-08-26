import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_delivery_page.dart';
import 'search_delivery_page.dart';
import 'search_sn_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracker'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _HomeTile(
              icon: Icons.add_box_outlined,
              title: 'Add Delivery',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddDeliveryPage())),
            ),
            _HomeTile(
              icon: Icons.search,
              title: 'Search Delivery',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchDeliveryPage())),
            ),
            _HomeTile(
              icon: Icons.qr_code_2,
              title: 'Search SN',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchSNPage())),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _HomeTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
