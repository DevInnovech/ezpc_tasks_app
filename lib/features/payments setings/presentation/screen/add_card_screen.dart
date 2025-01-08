import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  bool _isLoading = false;
  final CardFormEditController controller = CardFormEditController();

  Future<void> addCard() async {
    setState(() => _isLoading = true);

    try {
      print('Step 1: Initializing payment method creation');

      // 1. Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      print('Payment Method created: ${paymentMethod.id}');

      // Get the currently logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is logged in.');
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found.');
      }

      print('User email: $email');

      // 2. Send to your backend
      print('Step 2: Sending payment method to backend');

      final response = await http.post(
        Uri.parse('https://addcard-kdtiuzlqjq-uc.a.run.app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': user.email, // Replace with actual user email
          'paymentMethodId': paymentMethod.id,
        }),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        print('Card added successfully on backend');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
        Navigator.pop(context);
      } else {
        print('Error from backend: ${result['error']}');
        throw Exception(result['error'] ?? 'Failed to add card.');
      }
    } catch (e) {
      print('Error occurred: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountType = ref.watch(accountTypeProvider);

    if (accountType != AccountType.client &&
        accountType != AccountType.independentProvider) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Card')),
        body: const Center(
          child: Text('Access restricted to clients and providers only.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Card',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CardFormField(
                  controller: controller,
                  style: CardFormStyle(
                    borderRadius: 12,
                    borderWidth: 1,
                    borderColor: Colors.grey,
                    textColor: Colors.black,
                    fontSize: 16,
                    placeholderColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
