class Product {
  int? id;
  int? deliveryId;
  String sn;
  String description;

  Product(
      {this.id, this.deliveryId, required this.sn, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'deliveryId': deliveryId,
      'sn': sn,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      deliveryId: map['deliveryId'],
      sn: map['sn'],
      description: map['description'],
    );
  }
}
