import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class PaymentInformationScreen extends ConsumerStatefulWidget {
  const PaymentInformationScreen({super.key});

  @override
  ConsumerState<PaymentInformationScreen> createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState
    extends ConsumerState<PaymentInformationScreen> {
  bool _isLoading = false;
  final CardFormEditController _controller = CardFormEditController();

  Future<void> _addPaymentMethod() async {
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

      // 2. Get current user email
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is logged in.');
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found.');
      }

      print('User email: $email');

      // 3. Send payment method to backend
      print('Step 2: Sending payment method to backend');
      final response = await http.post(
        Uri.parse('https://addcard-kdtiuzlqjq-uc.a.run.app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'paymentMethodId': paymentMethod.id,
        }),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        print('Payment method added successfully on backend');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully!')),
        );

        Navigator.pushNamed(
          context,
          RouteNames.verificationSelectionScreen,
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to add payment method.');
      }
    } catch (e) {
      print('Error occurred: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Payment Information"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Add a Payment Method',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              Utils.verticalSpace(10),
              CardFormField(
                controller: _controller,
                style: CardFormStyle(
                  borderRadius: 12,
                  borderWidth: 1,
                  borderColor: Colors.grey.shade300,
                  textColor: Colors.black,
                  fontSize: 16,
                  placeholderColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: _isLoading ? "Processing..." : "Save Payment Method",
                onPressed: _isLoading ? null : _addPaymentMethod,
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: "Skip - Do it later",
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.authenticationScreen);
                },
                bgColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
