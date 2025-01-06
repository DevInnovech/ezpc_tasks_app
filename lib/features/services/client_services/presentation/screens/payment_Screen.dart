import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentModel paymentModel;

  const PaymentScreen({
    super.key,
    required this.paymentModel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _saveCard = false;
  String? _selectedCard;
  List<Map<String, dynamic>> _savedCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://stripepaymentintentrequest-kdtiuzlqjq-uc.a.run.app/list-cards"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.paymentModel.userEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _savedCards = List<Map<String, dynamic>>.from(data['cards'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading saved cards: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> processPayment(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final paymentData = {
        ...widget.paymentModel.toJson(),
        'saveCard': _saveCard,
        'savedCardId': _selectedCard,
      };

      final response = await http.post(
        Uri.parse("https://stripepaymentintentrequest-kdtiuzlqjq-uc.a.run.app"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el indicador de carga

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Payment processed successfully: $responseData");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment processed successfully")),
        );
        if (_saveCard) {
          _loadSavedCards(); // Recargar las tarjetas guardadas
        }
      } else {
        debugPrint("Failed to process payment: ${response.body}");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el indicador de carga
      debugPrint("Error processing payment: $e");
      // ignore: use_build_context_synchronously
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
      body: SingleChildScrollView(
        child: Padding(
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
              Text("Task ID: ${widget.paymentModel.taskId}"),
              Text("Time Slot: ${widget.paymentModel.timeSlot}"),
              Text("Date: ${widget.paymentModel.date.toLocal()}"),
              Text("Category: ${widget.paymentModel.selectedCategory}"),
              Text(
                "Subcategories: ${widget.paymentModel.selectedSubCategories.join(', ')}",
              ),
              Text(
                "Service Sizes: ${widget.paymentModel.serviceSizes.entries.where((entry) => entry.value > 0).map((entry) => "${entry.key} (${entry.value})").join(', ')}",
              ),
              Text(
                "Total Price: \$${widget.paymentModel.totalPrice.toStringAsFixed(2)}",
              ),
              Text("User Name: ${widget.paymentModel.userName}"),
              const SizedBox(height: 20),

              // Sección de tarjetas guardadas
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_savedCards.isNotEmpty) ...[
                const Text(
                  "Saved Cards",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...(_savedCards.map((card) => RadioListTile<String>(
                      title: Text('**** **** **** ${card['last4']}'),
                      subtitle: Text(
                          '${card['brand']} - Expires ${card['exp_month']}/${card['exp_year']}'),
                      value: card['id'],
                      groupValue: _selectedCard,
                      onChanged: (value) {
                        setState(() => _selectedCard = value);
                      },
                    ))),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedCard = null);
                  },
                  child: const Text("Use a new card"),
                ),
              ],

              // Opción de guardar tarjeta (solo visible si no se seleccionó una tarjeta guardada)
              if (_selectedCard == null)
                CheckboxListTile(
                  title: const Text("Save card for future payments"),
                  value: _saveCard,
                  onChanged: (value) {
                    setState(() => _saveCard = value ?? false);
                  },
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => processPayment(context),
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
      ),
    );
  }
}
