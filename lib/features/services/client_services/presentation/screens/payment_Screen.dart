import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'payment_model.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentModel paymentModel;

  const PaymentScreen({
    Key? key,
    required this.paymentModel,
    required String userName,
    required String timeSlot,
    required String taskId,
  }) : super(key: key);

  Future<void> processPayment() async {
    const String apiUrl = "https://api.yourserver.com/payment-intent";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(paymentModel.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Payment processed successfully: $responseData");
      } else {
        debugPrint("Failed to process payment: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error processing payment: $e");
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
                await processPayment();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment process initiated")),
                );
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
