// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

// class ShipmentScheduleCard extends StatelessWidget {
//   final Shipment shipment;

//   const ShipmentScheduleCard({
//     required this.shipment,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final order = shipment.serviceOrdered;

//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// TITLE + STATUS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   order?.title ?? 'Service',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 StatusChip(status: shipment.shipmentStatus),
//               ],
//             ),

//             const SizedBox(height: 10),

//             /// SERVICE NAME
//             Text(
//               order?.serviceRequired?.serviceName ?? 'Unknown service',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//               ),
//             ),

//             const SizedBox(height: 8),

//             /// DATE & TIME
//             Row(
//               children: [
//                 const Icon(Icons.schedule, size: 18),
//                 const SizedBox(width: 6),
//                 Text(
//                   '${shipment.shipmentScheduleDate} • ${shipment.shipmentScheduleTime}',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             /// PROVIDER
//             if (order?.?.fullName != null)
//               Row(
//                 children: [
//                   const Icon(Icons.person, size: 18),
//                   const SizedBox(width: 6),
//                   Text(
//                     order!.providerForService!.provider!.fullName!,
//                   ),
//                 ],
//               ),

//             const SizedBox(height: 12),

//             /// ACTION
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   // TODO: Navigate to shipment details / tracking
//                 },
//                 child: const Text('View Details'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
