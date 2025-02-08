import 'dart:convert';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;

class ConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ConfirmationScreen({
    super.key,
    required this.bookingData,
  });

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool isLoading = false;

  Future<void> saveBookingToFirestoreAfterPayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No authenticated user found.");

      // Generar un ID único para la reserva
      final bookingId =
          FirebaseFirestore.instance.collection('bookings').doc().id;

      final bookingData = {
        ...widget.bookingData,
        'bookingId': bookingId,
        'customerId': user.uid,
        'status': 'pending',
        'paymentStatus': 'Paid',
      };

      // Guardar la reserva en Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);

      debugPrint("Booking saved successfully.");

      // Crear la transacción en Firestore
      await saveTransactionToFirestore(
        providerId: widget.bookingData['providerId'],
        customerId: user.uid,
        bookingId: bookingId,
        amount: widget.bookingData['totalPrice'] ?? 0.0,
        service: widget.bookingData['selectedTaskName'] ?? 'Unknown Service',
        transactionType: 'payment',
        paymentStatus: 'completed',
        status: 'completed',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking and transaction saved!')),
      );

      // Navegar a la pantalla principal del cliente
      Navigator.pushNamed(context, RouteNames.ClientmainScreen);
    } catch (e) {
      debugPrint("Failed to save booking and transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking and transaction: $e')),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildProgressStep("Task", isCompleted: true),
        _buildProgressStep("Information", isCompleted: true),
        _buildProgressStep("Confirm", isCompleted: true),
      ],
    );
  }

  Widget _buildProgressStep(String title, {required bool isCompleted}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          child: Icon(
            isCompleted ? Icons.check : Icons.circle_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Client Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Name: ${widget.bookingData['clientName']}"),
            Text("Phone: ${widget.bookingData['clientPhone']}"),
            Text("Email: ${widget.bookingData['clientEmail']}"),
            Text("Address: ${widget.bookingData['clientAddress']}"),
            if (widget.bookingData['shortNotes'] != null &&
                widget.bookingData['shortNotes'].isNotEmpty)
              Text("Notes: ${widget.bookingData['shortNotes']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Provider Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Provider ID: ${widget.bookingData['providerId']}"),
            Text("Name: ${widget.bookingData['providerName']}"),
            Text("Email: ${widget.bookingData['providerEmail']}"),
            Text("Phone: ${widget.bookingData['providerPhone']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    final subCategories = widget.bookingData['selectedSubCategories'];
    final subCategoriesText = (subCategories != null && subCategories is List)
        ? subCategories.join(', ')
        : 'No details available';

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Category: ${widget.bookingData['selectedCategory']}"),
            Text("Task Name: ${widget.bookingData['selectedTaskName']}"),
            Text("Date: ${widget.bookingData['date']}"),
            Text("Time: ${widget.bookingData['timeSlot']}"),
            Text("Service Details: $subCategoriesText"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Information",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildPriceBreakdown(
                widget.bookingData['selectedSubCategoriesmap']),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(Map<String, dynamic> newPrices) {
    double servicesTotal =
        newPrices.values.fold(0.0, (sum, price) => sum + price);

    double taxRate = 0.1; // 10% impuestos
    double taxAmount = servicesTotal * taxRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...newPrices.entries.map((entry) {
          return _buildPriceRow(
            entry.key, // Nombre del servicio
            entry.value, // Precio sin multiplicar por horas
          );
        }),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow("Tasks Price (Subtotal):", servicesTotal),
        _buildPriceRow(
            "Taxes (10%):", double.parse(taxAmount.toStringAsFixed(2))),
        const Divider(
          height: 20,
          thickness: 1,
          color: Colors.grey,
        ),
        _buildPriceRow(
          "Total:",
          (servicesTotal + taxAmount),
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, dynamic value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "\$$value",
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF404C8C) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? intentPaymentData;

  Future<Map<String, dynamic>> makeIntentForPayment(
      String amountToBeCharged, String currency, bool saveCard) async {
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
        "taskId": widget.bookingData['taskId'],
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

  Future<void> paymentSheetInitialization(
      double amountToBeCharged, String currency, bool saveCard) async {
    try {
      // Llamar a la Firebase Function para obtener el PaymentIntent
      final intentPaymentData = await makeIntentForPayment(
        amountToBeCharged.toString(),
        currency,
        saveCard,
      );

      // Verificar si el intent contiene el client_secret
      if (intentPaymentData["paymentIntent"] == null) {
        throw Exception("Client secret not found in payment intent");
      }

      // Inicializar el Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentPaymentData["paymentIntent"],
          style: ThemeMode.light,
          merchantDisplayName: "Ezpc Tasks",
          allowsDelayedPaymentMethods: true,
        ),
      );

      // Mostrar el Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      // Aquí puedes llamar a una función para guardar los datos de la reserva
      await saveBookingToFirestoreAfterPayment();
    } catch (error) {
      debugPrint('Error initializing payment sheet: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $error")),
      );
    }
  }

  /// Guardar el estado del pago en Firebase
  Future<void> savePaymentStatus(String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      final bookingId = widget.bookingData['bookingId'];
      if (bookingId == null || bookingId.isEmpty) {
        throw Exception("Booking ID is missing.");
      }

      // Actualizar el estado del pago en Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'paymentStatus': status});

      if (kDebugMode) {
        print("Payment status updated to $status for booking $bookingId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update payment status: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update payment status: $e')),
      );
    }
  }

  Future<void> saveTransactionToFirestore({
    required String providerId,
    required String customerId,
    required String bookingId,
    required double amount,
    required String service,
    required String transactionType,
    required String paymentStatus,
    required String status,
  }) async {
    try {
      // Generar un ID único para la transacción
      final transactionId =
          FirebaseFirestore.instance.collection('transactions').doc().id;

      // Crear los datos de la transacción
      final transactionData = {
        'transactionId': transactionId,
        'amount': amount,
        'currency': 'USD',
        'providerId': providerId,
        'customerId': customerId,
        'service': service,
        'transactionType': transactionType, // Ej: 'payment' o 'withdraw'
        'paymentStatus': paymentStatus, // Ej: 'hold', 'completed'
        'status': status, // Ej: 'pending', 'completed'
        'type': 'booking', // Puede ser 'booking', 'task', etc.
        'withdrawStatus': 'not_started',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'details': {
          'bookingId': bookingId,
          'description': 'Payment for service booked',
          'paymentStatus': paymentStatus,
          'providerId': providerId,
        },
      };

      // Guardar la transacción en Firestore
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .set(transactionData);

      debugPrint("Transaction added successfully.");
    } catch (e) {
      debugPrint("Failed to save transaction: $e");
    }
  }

  showPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      // Guardar el booking después del pago exitoso
      await saveBookingToFirestoreAfterPayment();

      // Mostrar tarjeta de éxito
      showDialog(
        context: context,
        builder: (_) => _buildSuccessDialog(),
      );

      setState(() {
        intentPaymentData = null; // Reiniciar el intent después del éxito
      });
    } on stripe.StripeException catch (e) {
      // Validar si el código de error es por cancelación del flujo de pago
      if (e.error.localizedMessage?.contains("canceled") ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment cancelled.")),
        );
      } else {
        // Otro error de Stripe
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed.")),
        );
      }
    } catch (error) {
      // Manejo de cualquier otro tipo de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed.")),
      );
    }
  }

  /// Tarjeta de éxito del pago
  Widget _buildSuccessDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF404C8C),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Great",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF404C8C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Payment Success",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Payment for service successfully done",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const Divider(height: 24),
          const Text(
            "Total Payment",
            style: TextStyle(fontSize: 14),
          ),
          Text(
            "\$${widget.bookingData['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF404C8C),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              final double totalPrice = widget.bookingData['totalPrice'] ?? 0.0;

              // Llamar la función con los argumentos requeridos
              await paymentSheetInitialization(
                totalPrice, // Monto total
                "USD", // Moneda
                true, // Guardar tarjeta para uso futuro
              );
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: const Color(0xFF404C8C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              "Pay Now (\$${widget.bookingData['totalPrice']?.toStringAsFixed(2) ?? '0.00'})",
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _buildProgressIndicator(),
              const SizedBox(height: 24.0),
              _buildClientInfoCard(),
              const SizedBox(height: 16.0),
              _buildProviderInfoCard(), // Tarjeta de información del proveedor
              const SizedBox(height: 16.0),
              _buildTaskInfoCard(),
              const SizedBox(height: 16.0),
              _buildPaymentInfoCard(),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildProceedButton(),
      ),
    );
  }
}
