import 'dart:convert';
import 'package:ezpc_tasks_app/features/services/client_services/data/PaymentKeys.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
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

  Future<void> saveBookingToFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener el ID del cliente autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      final bookingId =
          FirebaseFirestore.instance.collection('bookings').doc().id;

      final bookingData = {
        ...widget.bookingData,
        'bookingId': bookingId,
        'customerId': user.uid, // ID del cliente autenticado
        'status': 'pending', // Estado inicial
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId) // Guardar usando el bookingId generado
          .set(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully!')),
      );

      // Navegar a la pantalla de pago
      Navigator.pushNamed(context, '/payment');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
    final categoryPrice = widget.bookingData['categoryPrice'] ?? 0.0;
    final taskPrice = widget.bookingData['taskPrice'] ?? 0.0;
    final taxes = (categoryPrice + taskPrice) * 0.1; // 10% de impuestos
    final totalPrice = widget.bookingData['totalPrice'] ?? 0.0;

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
            _buildPriceRow("Category Price", categoryPrice),
            _buildPriceRow("Task Price", taskPrice),
            _buildPriceRow("Taxes (10%)", taxes),
            const Divider(),
            _buildPriceRow(
              "Total",
              totalPrice,
              isBold: true,
              textColor: const Color(0xFF404C8C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double price,
      {bool isBold = false, Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\$${price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? intentPaymentData;

  makeIntentForPayment(String amountToBeCharged, String currency) async {
    try {
      // Convertir el monto a centavos
      final int amountInCents = (double.parse(amountToBeCharged) * 100).toInt();

      // Crear los datos de la intención de pago
      Map<String, dynamic> paymentInfo = {
        "amount": amountInCents.toString(), // Cantidad en centavos
        "currency": currency, // Moneda
        "payment_method_types[]":
            "card", // Este debe enviarse como un parámetro con `[]`
      };

      // Realizar la solicitud a Stripe
      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $SecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (responseFromStripeAPI.statusCode == 200) {
        // Parsear la respuesta
        return jsonDecode(responseFromStripeAPI.body);
      } else {
        throw Exception(
            "Error from Stripe: ${responseFromStripeAPI.statusCode} - ${responseFromStripeAPI.body}");
      }
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      throw Exception("Failed to create payment intent: $errorMsg");
    }
  }

  paymentSheetInitialization(double amountToBeCharged, String currency) async {
    try {
      // Convertir el monto a String y llamar al Intent
      intentPaymentData =
          await makeIntentForPayment(amountToBeCharged.toString(), currency);

      // Verificar si el intent contiene el client_secret
      if (intentPaymentData?["client_secret"] == null) {
        throw Exception("Client secret not found in payment intent");
      }

      // Inicializar el Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Ezpc Tasks",
        ),
      );

      // Mostrar el Payment Sheet
      await showPaymentSheet();
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing payment sheet: $error');
      }
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

  showPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      // Guardar en Firestore con `paymentStatus` como "Paid"
      await savePaymentStatus("Paid");

      // Mostrar tarjeta de éxito
      showDialog(
        context: context,
        builder: (_) => _buildSuccessDialog(),
      );

      setState(() {
        intentPaymentData = null; // Reiniciar el intent después del éxito
      });
    } on stripe.StripeException catch (error) {
      if (kDebugMode) {
        print("StripeException: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment cancelled.")),
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error showing payment sheet: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $error")),
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
              final double totalPrice = widget.bookingData['totalPrice'] ??
                  0.0; // Extraer el totalPrice
              await paymentSheetInitialization(
                  totalPrice, "USD"); // Llamar la función con totalPrice
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
