import 'product.dart';

class Delivery {
  String? id;
  String client;
  String phone;
  String note;
  String date; // will always store current date
  List<Product> products;

  Delivery({
    this.id,
    required this.client,
    required this.phone,
    required this.note,
    required this.products,
  }) : date = DateTime.now().toIso8601String(); // current date automatically

  Map<String, dynamic> toMap() {
    return {
      'client': client,
      'phone': phone,
      'note': note,
      'date': DateTime.now().toString(),
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map, List<Product> products) {
    return Delivery(
      id: map['id'],
      client: map['client'],
      phone: map['phone'],
      note: map['note'],
      products: products,
      //date : map[''],
    );
  }
}

// class Delivery {
//   int? id;
//   String client;
//   String phone;
//   String note;
//   String date; // YYYY-MM-DD
//   List<Product> products;

//   Delivery({
//     this.id,
//     required this.client,
//     required this.phone,
//     required this.note,
//     required this.date,
//     required this.products,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'client': client,
//       'phone': phone,
//       'note': note,
//       'date': date,
//     };
//   }

//   factory Delivery.fromMap(Map<String, dynamic> map, List<Product> products) {
//     return Delivery(
//       id: map['id'],
//       client: map['client'],
//       phone: map['phone'],
//       note: map['note'],
//       products: products,
//        date : map[''],
//     );
//   }
// }
