import 'package:cloud_firestore/cloud_firestore.dart';

/// Cached map of SN prefixes → product descriptions
Map<String, String> _snPrefixCache = {};

/// Load prefixes from Firestore (call this at app start or first use)
Future<void> loadSnPrefixesFromFirebase() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('sn_prefixes').get();

  _snPrefixCache = {
    for (var doc in snapshot.docs) doc.id.toUpperCase(): doc['description']
  };
}

/// Get product type from SN
String productTypeFromSN(String sn) {
  for (final entry in _snPrefixCache.entries) {
    if (sn.toUpperCase().startsWith(entry.key)) {
      return entry.value;
    }
  }
  return 'Unknown Product';
}
