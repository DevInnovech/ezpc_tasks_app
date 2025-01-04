import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'payment_model.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentModel paymentModel;

  const PaymentScreen({
    super.key,
    required this.paymentModel,
  });

  Future<void> processPayment(BuildContext context) async {
    const String apiUrl =
        "https://stripepaymentintentrequest-kdtiuzlqjq-uc.a.run.app";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(paymentModel.toJson()),
      );

      Navigator.of(context).pop(); // Cierra el indicador de carga

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Payment processed successfully: $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment processed successfully")),
        );
      } else {
        debugPrint("Failed to process payment: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el indicador de carga
      debugPrint("Error processing payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review Payment Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text("Task ID: ${paymentModel.taskId}"),
            Text("Time Slot: ${paymentModel.timeSlot}"),
            Text("Date: ${paymentModel.date.toLocal()}"),
            Text("Category: ${paymentModel.selectedCategory}"),
            Text(
                "Subcategories: ${paymentModel.selectedSubCategories.join(', ')}"),
            Text(
              "Service Sizes: ${paymentModel.serviceSizes.entries.where((entry) => entry.value > 0).map((entry) => "${entry.key} (${entry.value})").join(', ')}",
            ),
            Text(
                "Total Price: \$${paymentModel.totalPrice.toStringAsFixed(2)}"),
            Text("User Name: ${paymentModel.userName}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await processPayment(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Proceed with Payment",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
