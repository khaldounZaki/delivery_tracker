/// Map your SN prefixes to product descriptions here.
const Map<String, String> snPrefixMap = {
  'MB-700FRS': 'Single Door Freezer',
  'MB-900REF': 'Double Door Refrigerator',
  'MB-600CHL': 'Chiller Cabinet',
};

String productTypeFromSN(String sn) {
  for (final entry in snPrefixMap.entries) {
    if (sn.toUpperCase().startsWith(entry.key.toUpperCase())) {
      return entry.value;
    }
  }
  return 'Unknown Product';
}
