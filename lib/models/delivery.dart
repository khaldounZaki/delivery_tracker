import 'product.dart';

class Delivery {
  int? id;
  String client;
  String phone;
  String note;
  List<Product> products;

  Delivery({
    this.id,
    required this.client,
    required this.phone,
    required this.note,
    required this.products,
  });

  Map<String, dynamic> toMap() {
    return {
      'client': client,
      'phone': phone,
      'note': note,
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map, List<Product> products) {
    return Delivery(
      id: map['id'],
      client: map['client'],
      phone: map['phone'],
      note: map['note'],
      products: products,
    );
  }
}
