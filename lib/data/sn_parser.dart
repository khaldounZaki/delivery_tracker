/// Map your SN prefixes to product descriptions here.
const Map<String, String> snPrefixMap = {
  'MB-700FRS': 'Single Door Freezer',
  'MB-700CHS': 'Single Door Chiller',
  'MB-1400FRS': 'Double Door Chiller',
};

String productTypeFromSN(String sn) {
  for (final entry in snPrefixMap.entries) {
    if (sn.toUpperCase().startsWith(entry.key.toUpperCase())) {
      return entry.value;
    }
  }
  return 'Unknown Product';
}
