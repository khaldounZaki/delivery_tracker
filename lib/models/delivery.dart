class Delivery {
  final int? id;
  final String sn;
  final String productType;
  final String clientName;
  final String clientPhone;
  final String clientAddress;
  final String deliveredBy;
  final DateTime deliveredAt;

  Delivery({
    this.id,
    required this.sn,
    required this.productType,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.deliveredBy,
    required this.deliveredAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sn': sn,
    'product_type': productType,
    'client_name': clientName,
    'client_phone': clientPhone,
    'client_address': clientAddress,
    'delivered_by': deliveredBy,
    'delivered_at': deliveredAt.millisecondsSinceEpoch,
  };

  factory Delivery.fromMap(Map<String, dynamic> m) => Delivery(
    id: m['id'] as int?,
    sn: m['sn'] as String,
    productType: m['product_type'] as String,
    clientName: m['client_name'] as String,
    clientPhone: m['client_phone'] as String,
    clientAddress: m['client_address'] as String,
    deliveredBy: m['delivered_by'] as String,
    deliveredAt: DateTime.fromMillisecondsSinceEpoch(m['delivered_at'] as int),
  );
}
