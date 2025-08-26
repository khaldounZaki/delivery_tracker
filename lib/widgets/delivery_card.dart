// import 'package:flutter/material.dart';
// import '../models/delivery.dart';
// import 'package:intl/intl.dart';

// class DeliveryCard extends StatelessWidget {
//   final Delivery delivery;
//   const DeliveryCard({super.key, required this.delivery});

//   @override
//   Widget build(BuildContext context) {
//     final fmt = DateFormat('yyyy-MM-dd HH:mm');
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.qr_code_2),
//                 const SizedBox(width: 8),
//                 Expanded(child: Text(delivery.sn, style: const TextStyle(fontWeight: FontWeight.bold))),
//                 const SizedBox(width: 8),
//                 Chip(label: Text(delivery.productType)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text('Client: ${delivery.clientName} (${delivery.clientPhone})'),
//             Text('Address: ${delivery.clientAddress}'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Text('By: ${delivery.deliveredBy}'),
//                 const Spacer(),
//                 Text(fmt.format(delivery.deliveredAt)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
