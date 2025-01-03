import 'dart:convert';

import 'package:ezpc_tasks_app/features/services/client_services/data/PaymentKeys.dart';
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
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.order});

  final OrderDetailsDto order;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExtraTimeRequest(context, widget.order.orderId);
    });
  }

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

  Future<void> _checkExtraTimeRequest(
      BuildContext context1, String orderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .get();

      if (doc.exists && doc.data()?['extraTime'] != null) {
        final extraTime = doc.data()?['extraTime'];
        if (extraTime['status'] == 'Pending') {
          _openExtraTimeApprovalDialog(context1, orderId, extraTime);
        }
      }
    } catch (e) {
      debugPrint("Error fetching extra time details: $e");
    }
  }

  void _openExtraTimeApprovalDialog(
      BuildContext context1, String orderId, Map<String, dynamic> extraTime) {
    showDialog(
      context: context1,
      barrierDismissible: false, // No permite cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Bloquea el botón de retroceso
          child: AlertDialog(
            title: const Text('Extra Time Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duration:'),
                    Text(extraTime['selectedDuration']),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time Slot:'),
                    Text(extraTime['selectedTimeSlot']),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reason:'),
                    Expanded(
                      child: Text(extraTime['reason']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fee:'),
                    Text('\$${extraTime['fee']}'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateExtraTimeStatus(orderId, 'Declined');
                },
                child:
                    const Text('Decline', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Cerrar el diálogo antes de proceder

                  final extraTimeFee = extraTime['fee'] ?? 0.0;

                  // Iniciar el flujo de pago
                  final isPaymentSuccessful =
                      await _processPayment(extraTimeFee, orderId);

                  if (isPaymentSuccessful) {
                    // Actualizar el estado de `Extra Time` a "Accepted"
                    await _updateExtraTimeStatus(orderId, 'Accepted');

                    ScaffoldMessenger.of(context1).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Payment successful. Extra Time Accepted."),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Payment failed. Please try again."),
                      ),
                    );
                  }
                },
                child: const Text('Accept'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _processPayment(double fee, String orderId) async {
    try {
      // Crear intención de pago
      final intentPaymentData =
          await makeIntentForPayment(fee.toString(), "USD");

      // Verificar si el client_secret existe
      if (intentPaymentData?["client_secret"] == null) {
        throw Exception("Payment intent failed to generate.");
      }

      // Inicializar el Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentPaymentData["client_secret"],
          merchantDisplayName: "Ezpc Tasks",
        ),
      );

      // Mostrar el Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet();

      // Actualizar estado del pago en Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({'extraTime.paymentStatus': 'Paid'});

      return true; // Retornar éxito
    } catch (e) {
      debugPrint("Payment error: $e");
      return false; // Retornar fallo
    }
  }

  Future<Map<String, dynamic>> makeIntentForPayment(
      String amount, String currency) async {
    try {
      final int amountInCents = (double.parse(amount) * 100).toInt();

      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": "Bearer $SecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "amount": amountInCents.toString(),
          "currency": currency,
          "payment_method_types[]": "card",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create payment intent: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating payment intent: $e");
    }
  }

  Future<void> _updateExtraTimeStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({
        'extraTime.status': status,
      });

      // Notificar al proveedor sobre la decisión
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'extra_time_response',
        'bookingId': orderId,
        'message': 'Your extra time request has been $status.',
        'status': 'unread',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("Extra time status updated to $status.");
    } catch (e) {
      debugPrint("Error updating extra time status: $e");
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
          data: widget.order,
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

  Widget _buildExtraTimeCard(Map<String, dynamic> extraTime) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Extra Time Details",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Duration: ${extraTime['selectedDuration']}"),
            Text("Time Slot: ${extraTime['selectedTimeSlot']}"),
            Text("Reason: ${extraTime['reason']}"),
            Text("Fee: \$${extraTime['fee']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extraTime = data.extraTime;
    print(data.extraTime);
    final validStatusesSetA = <String>{
      'started',
      'in progress',
    };

    final validStatusesSetB = <String>{
      'on_the_way',
      'arrived',
      // etc...
    };

    Color _determineColor() {
      final status = data.status.toLowerCase();

      final statusb = data.providerStatus.toLowerCase();

      if (validStatusesSetA.contains(status) ||
          validStatusesSetB.contains(statusb)) {
        // Color si pertenece a setA
        return const Color(0xFF404C8C);
      } else {
        // Color si no coincide con ninguno
        return Colors.grey;
      }
    }

    Function()? _determineOnPressed() {
      final status = data.status.toLowerCase();

      final statusb = data.providerStatus.toLowerCase();

      if (validStatusesSetA.contains(status)) {
        // Caso 1: está en el primer conjunto
        return () {
          // Acciones para setA
          Navigator.pushNamed(
            context,
            RouteNames.providerTracking,
            arguments: data,
          );
        };
      } else if (validStatusesSetB.contains(statusb)) {
        // Caso 2: está en el segundo conjunto
        return () {
          // Acciones para setB
          Navigator.pushNamed(
            context,
            RouteNames.providerTracking,
            arguments: data,
          );
        };
      } else {
        // Caso 3: no está en ninguno de los conjuntos => botón deshabilitado
        return null;
      }
    }

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

              if (extraTime != null && extraTime['status'] == 'Accepted')
                _buildExtraTimeCard(extraTime), // Mostrar solo si está aceptado

              Utils.verticalSpace(20),
              // Tracking Button
              // Track Provider Button
              PrimaryButton(
                text: "Track Provider",
                onPressed: _determineOnPressed(), // Disabled if not "started"
                bgColor: _determineColor(), // Gray if disabled
              ),
              Utils.verticalSpace(10),

// Cancel Order Button
              PrimaryButton(
                text: "Cancel Order",
                onPressed: (data.status.toLowerCase() == "in progress" ||
                        data.status.toLowerCase() == "completed" ||
                        data.status.toLowerCase() == "cancelled")
                    ? null // Disabled if "started", "completed", or "cancelled"
                    : () => onCancel(
                        context, data.orderId), // Only active for other states
                bgColor: (data.status.toLowerCase() == "in progress" ||
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
