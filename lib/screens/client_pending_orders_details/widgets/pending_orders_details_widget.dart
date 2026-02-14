import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/detail_cards.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/header_section.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/negotiation_button.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/service_images_card.dart';

class PendingOrderDetailBody extends StatelessWidget {
  final OrderServiceModel booking;
  final int orderId;

  const PendingOrderDetailBody({super.key, required this.booking, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Kolors.kDark ?? Colors.black87;
    final secondaryTextColor = Colors.grey.shade700;

    return Container(
      decoration: BoxDecoration(
        color: Kolors.kWhite ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(title: booking.title ?? "SERVICE REQUEST", status: booking.status),
            const SizedBox(height: 24),
            RequestDetailsCard(booking: booking, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor),
            const SizedBox(height: 20),
            DeliveryAddressCard(booking: booking, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor),
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              NotesCard(booking: booking, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor),
            ],
            if (booking.servicePictures != null && booking.servicePictures!.isNotEmpty) ...[
              const SizedBox(height: 20),
              ServiceImagesImages(booking: booking, primaryTextColor: primaryTextColor),
            ],
            const SizedBox(height: 30),
            NegotiationButton(orderId: orderId),
          ],
        ),
      ),
    );
  }
}
