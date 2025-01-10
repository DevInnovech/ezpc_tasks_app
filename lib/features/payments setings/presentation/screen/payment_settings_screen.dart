import 'dart:convert';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/add_bank_account_screen.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

// Configuración de cifrado
final key = encrypt.Key.fromUtf8(
    'your32charsecureencryptionkey'); // Clave de 32 caracteres
final iv = encrypt.IV.fromLength(16); // Vector de inicialización
final encrypter = encrypt.Encrypter(encrypt.AES(key));

final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _bankAccounts = [];
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

      // Fetch methods based on account type
      if (accountType == 'Client') {
        await _fetchPaymentMethodsFromStripe(email);
      } else if (accountType == 'Independent Provider') {
        await _fetchBankAccountsFromFirebase(user.uid);
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

  /// Fetch payment methods (cards) from Stripe using Firebase Functions
  Future<void> _fetchPaymentMethodsFromStripe(String email) async {
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

  /// Fetch bank accounts from Firebase Firestore
  Future<void> _fetchBankAccountsFromFirebase(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bank_accounts')
        .where('user_id', isEqualTo: userId)
        .get();

    _bankAccounts = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'bank_name': data['bank_name'],
        'account_holder_name': data['account_holder_name'],
        'account_number': _decrypt(data['account_number']),
        'routing_number': _decrypt(data['routing_number']),
        'account_type': data['account_type'],
      };
    }).toList();
  }

  /// Decrypt the data
  String _decrypt(String encryptedData) {
    try {
      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      print('Error decrypting data: $e');
      return 'Decryption error';
    }
  }

  /// Fetch account type from Firestore
  Future<String> _fetchAccountType() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is logged in.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found in Firestore.');
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey('accountType')) {
        throw Exception('Account type not found.');
      }

      final accountType = data['accountType'] as String;
      return accountType;
    } catch (e) {
      throw Exception('Failed to fetch account type: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
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
                          Text(
                            accountType == 'Client'
                                ? 'Pay with'
                                : 'Bank Accounts',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (accountType == 'Client')
                            ..._paymentMethods
                                .map((method) => _buildPaymentMethodTile(
                                      context,
                                      methodId: method['id'],
                                      title: '**** ${method['last4']}',
                                      subtitle: method['brand'],
                                      icon: Icons.credit_card,
                                    )),
                          if (accountType == 'Independent Provider')
                            ..._bankAccounts
                                .map((account) => _buildPaymentMethodTile(
                                      context,
                                      methodId: account['id'],
                                      title: account['bank_name'] ?? '',
                                      subtitle:
                                          'Account Holder: ${account['account_holder_name'] ?? ''}',
                                      icon: Icons.account_balance,
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
                if (accountType == 'Client')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCardScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.credit_card, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Credit or debit card'),
                      ],
                    ),
                  ),
                if (accountType == 'Independent Provider')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBankAccountScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.account_balance, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Bank Account'),
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
