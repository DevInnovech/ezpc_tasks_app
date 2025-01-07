import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_card_screen.dart';

final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;
  String? _error;
  String? accountType;

  /// Fetch payment methods based on account type
  Future<void> _fetchPaymentMethods() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get the currently logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is logged in.');
      }
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found.');
      }

      // Fetch account type
      accountType = await _fetchAccountType();

      // Fetch payment methods (cards) for clients or independent providers
      if (accountType == 'client' || accountType == 'independentProvider') {
        await _fetchPaymentMethodsFromServer(email);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  /// Fetch payment methods (cards) from Firebase Functions
  Future<void> _fetchPaymentMethodsFromServer(String email) async {
    final url =
        Uri.parse('https://listpaymentmethods-kdtiuzlqjq-uc.a.run.app/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _paymentMethods =
            List<Map<String, dynamic>>.from(data['paymentMethods']);
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch payment methods');
      }
    } else {
      throw Exception('Failed to fetch payment methods: ${response.body}');
    }
  }

  /// Simulate account type fetching (replace with real implementation)
  Future<String> _fetchAccountType() async {
    // Replace with real account type fetching logic
    return Future.value('client'); // Example value
  }

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Settings')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          const Text(
                            'Pay with',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (accountType == 'client' ||
                              accountType == 'independentProvider')
                            ..._paymentMethods
                                .map((method) => _buildPaymentMethodTile(
                                      context,
                                      methodId: method['id'],
                                      title: '**** ${method['last4']}',
                                      subtitle: method['brand'],
                                      icon: Icons.credit_card,
                                    )),
                        ],
                      ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADD PAYMENT METHOD',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (accountType == 'client' ||
                    accountType == 'independentProvider')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCardScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey, width: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.credit_card, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Credit or debit card',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context, {
    required String methodId,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selectedPaymentMethod == methodId
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        ref.read(selectedPaymentMethodProvider.notifier).state = methodId;
      },
    );
  }
}
