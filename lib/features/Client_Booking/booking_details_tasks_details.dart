import 'dart:convert';

import 'package:ezpc_tasks_app/shared/widgets/purchase_info_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                onPressed: () async {
                  bool confirmDecline = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Decline'),
                      content: const Text(
                          'Are you sure you want to decline this request?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  if (confirmDecline) {
                    Navigator.pop(context);
                    _updateExtraTimeStatus(orderId, 'Declined');
                  }
                },
                child:
                    const Text('Decline', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  bool confirmAccept = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Acceptance'),
                      content: const Text(
                          'Are you sure you want to accept this extra time request?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  if (!confirmAccept) return;

                  Navigator.pop(context); // Cerrar el diálogo antes de proceder
                  final extraTimeFee = extraTime['fee'] ?? 0.0;

                  final isPaymentSuccessful =
                      await _processPayment(extraTimeFee, orderId);

                  if (isPaymentSuccessful) {
                    await _updateExtraTimeStatus(orderId, 'Accepted');
                    ScaffoldMessenger.of(context1).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Payment successful. Extra Time Accepted."),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context1).showSnackBar(
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

  Future<Map<String, dynamic>> makeIntentForPayment(String amountToBeCharged,
      String currency, bool saveCard, String orderId) async {
    try {
      // Convertir el monto a centavos
      final int amountInCents = (double.parse(amountToBeCharged) * 100).toInt();

      // Obtener el usuario autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      // Crear los datos para enviar al backend
      Map<String, dynamic> requestData = {
        "amount": amountInCents,
        "currency": currency,
        "email": user.email,
        "userId": user.uid,
        "orderId": orderId,
        "saveCard": saveCard, // Indica si se desea guardar la tarjeta
      };

      // Realizar la solicitud POST al endpoint de la Firebase Function
      var response = await http.post(
        Uri.parse('https://stripepaymentintentrequest-kdtiuzlqjq-uc.a.run.app'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!responseData.containsKey('paymentIntent')) {
          throw Exception("paymentIntent not found in response");
        }
        return responseData;
      } else {
        throw Exception(
            "Failed to create payment intent: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      debugPrint("Error creating payment intent: $error");
      throw Exception("Failed to create payment intent: $error");
    }
  }

//verifica cris
  /* Future<bool> _processPayment(double fee, String orderId) async {
    try {

      
      // Crear intención de pago

      final intentPaymentData =  // Llamar la función con los argumentos requeridos
              await paymentSheetInitialization(
                totalPrice, // Monto total
                "USD", // Moneda
                true, // Guardar tarjeta para uso futuro
              );
       // await makeIntentForPayment(fee.toString(), "USD");

      // Verificar si el client_secret existe
      if (intentPaymentData["client_secret"] == null) {
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
*/
  Future<bool> _processPayment(double fee, String orderId) async {
    try {
      // Crear intención de pago
      final intentPaymentData =
          await makeIntentForPayment(fee.toString(), "USD", true, orderId
              // Guardar tarjeta para uso futuro
              );

      // Verificar si el client_secret existe
      if (intentPaymentData["paymentIntent"] == null) {
        throw Exception("Payment intent failed to generate.");
      }

      // Inicializar el Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentPaymentData["paymentIntent"],
          merchantDisplayName: "Ezpc Tasks",
          allowsDelayedPaymentMethods: true,
        ),
      );

      // Mostrar el Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet();

      // Actualizar estado del pago en Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({'extraTime.paymentStatus': 'Paid'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      return true; // Retornar éxito
    } on stripe.StripeException catch (e) {
      debugPrint("Stripe payment error: ${e.error.localizedMessage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: ${e.error.localizedMessage}")),
      );
      return false;
    } catch (e) {
      debugPrint("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
      return false;
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

    Color determineColor() {
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

    Function()? determineOnPressed() {
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
                onPressed: determineOnPressed(), // Disabled if not "started"
                bgColor: determineColor(), // Gray if disabled
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
                      ? CircleAvatar(
                          radius:
                              40.w, // Radio para definir el tamaño del círculo
                          backgroundColor:
                              Colors.grey[200], // Color de fondo del círculo
                          child: ClipOval(
                            child: CustomImage(
                              path: providerImage,
                              fit: BoxFit
                                  .cover, // Asegura que la imagen llene el círculo
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
                      /* Row(
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
                      ),*/
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
