import 'package:ezpc_tasks_app/shared/widgets/purchase_info_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/flutter_svg.dart";

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key, required this.order});

  final OrderDetailsDto order;

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({'status': 'cancelled'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order has been cancelled.')),
      );

      Navigator.pop(context); // Cierra la pantalla actual después de cancelar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    }
  }

  void _showCancelConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // Cierra el cuadro de diálogo
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el cuadro de diálogo
              _cancelOrder(context, orderId); // Cancela la orden
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Order Details"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: LoadedWidget(
          data: order,
          onCancel: _showCancelConfirmation,
        ),
      ),
    );
  }
}

class LoadedWidget extends StatelessWidget {
  const LoadedWidget({
    super.key,
    required this.data,
    required this.onCancel,
  });

  final OrderDetailsDto data;
  final Function(BuildContext, String) onCancel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.verticalSpace(6),
          ProviderInfo(
            provider: ProviderModel(
              name: data.providerName,
              email: data.providerEmail,
              phone: data.providerPhone,
              image: data.providerImageUrl,
              id: 0,
              rating: data.rating,
              reviews: 0,
            ),
            providerUserId: data.providerId,
          ),
          Utils.verticalSpace(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Details',
                style: TextStyle(
                  color: Color(0xFF051533),
                  fontSize: 18,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.67,
                ),
              ),
              Utils.verticalSpace(8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(children: [
                  Text(
                    data.taskName,
                    style: const TextStyle(
                      color: Color(0xFF535769),
                      fontSize: 18,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.67,
                    ),
                  ),
                  Utils.verticalSpace(8),
                  const Divider(),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Task Rate',
                    trailText: data.price.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Discount',
                    trailText: data.discount.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  Divider(color: Colors.grey[300]),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Subtotal',
                    trailText: (data.price - data.discount).toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Tax',
                    trailText: data.tax.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  Divider(color: Colors.grey[300]),
                  PurchaseInfoText(
                    text: 'Total',
                    trailText: data.total.toStringAsFixed(2),
                    textColor: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  Utils.verticalSpace(16),
                  PurchaseInfoStatus(
                    text: 'Payment Status',
                    trailText: data.paymentStatus,
                  ),
                ]),
              ),
              Utils.verticalSpace(20),
              const Text(
                'Task Status',
                style: TextStyle(
                  color: Color(0xFF051533),
                  fontSize: 18,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.67,
                ),
              ),
              Utils.verticalSpace(8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: PurchaseInfoStatus(
                  text: 'Task Status',
                  trailText: data.status,
                ),
              ),
              Utils.verticalSpace(20),
              // Tracking Button
              // Track Provider Button
              PrimaryButton(
                text: "Track Provider",
                onPressed: data.status.toLowerCase() == "started"
                    ? () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.providerTracking,
                          arguments: data,
                        );
                      }
                    : null, // Disabled if not "started"
                bgColor: data.status.toLowerCase() == "started"
                    ? const Color(0xFF404C8C) // Active color
                    : Colors.grey, // Gray if disabled
              ),
              Utils.verticalSpace(10),

// Cancel Order Button
              PrimaryButton(
                text: "Cancel Order",
                onPressed: (data.status.toLowerCase() == "started" ||
                        data.status.toLowerCase() == "completed" ||
                        data.status.toLowerCase() == "cancelled")
                    ? null // Disabled if "started", "completed", or "cancelled"
                    : () => onCancel(
                        context, data.orderId), // Only active for other states
                bgColor: (data.status.toLowerCase() == "started" ||
                        data.status.toLowerCase() == "completed" ||
                        data.status.toLowerCase() == "cancelled")
                    ? Colors.grey // Gray if disabled
                    : Colors.red, // Active color
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ProviderInfo extends StatelessWidget {
  const ProviderInfo({
    super.key,
    required this.provider,
    required this.providerUserId,
  });

  final ProviderModel provider;
  final String providerUserId;

  Future<Map<String, dynamic>?> _fetchProviderData() async {
    if (providerUserId.isEmpty) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(providerUserId)
        .get();

    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchProviderData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar un indicador de carga mientras se obtienen los datos
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Si ocurre un error, mostrar un mensaje
          return const Text("Error loading provider data");
        }

        final providerData = snapshot.data;
        // Si no hay datos, mostrar algo por defecto
        final providerName = providerData?['name'] ?? provider.name;
        final providerLastName = providerData?['lastName'] ?? '';
        final providerFullName = '$providerName $providerLastName'.trim();
        final providerPhone = providerData?['phoneNumber'] ?? provider.phone;
        final providerEmail = providerData?['email'] ?? provider.email;
        final providerImage =
            providerData?['profileImageUrl'] ?? provider.image;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider Details',
              style: TextStyle(
                color: Color(0xFF051533),
                fontSize: 18,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w600,
                height: 1.67,
              ),
            ),
            Utils.verticalSpace(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.provideraboutScreen,
                      arguments: {'userId': providerUserId},
                    );
                  },
                  child: (providerImage != null &&
                          providerImage != 'N/A' &&
                          providerImage.isNotEmpty)
                      ? Container(
                          width: 94.w,
                          height: 94.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: ClipOval(
                            child: CustomImage(
                              path: providerImage,
                              fit: BoxFit.cover,
                              url: null,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                Utils.horizontalSpace(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerFullName,
                        style: const TextStyle(
                          color: Color(0xFF051533),
                          fontSize: 18,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Utils.verticalSpace(8),
                      Row(
                        children: [
                          SvgPicture.asset(KImages.call),
                          Utils.horizontalSpace(4),
                          Text(
                            providerPhone ?? '',
                            style: const TextStyle(
                              color: Color(0xFF535769),
                              fontSize: 12,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Utils.verticalSpace(8),
                      Row(
                        children: [
                          SvgPicture.asset(KImages.booking),
                          Utils.horizontalSpace(4),
                          Text(
                            providerEmail ?? '',
                            style: const TextStyle(
                              color: Color(0xFF535769),
                              fontSize: 12,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ]),
            )
          ],
        );
      },
    );
  }
}
