import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

// Configuración de cifrado: Clave de 32 caracteres (256 bits)
final key =
    encrypt.Key.fromUtf8('abcdefghijklmnopqrstuvwxzy123456'); // 32 caracteres
final iv = encrypt.IV.fromLength(16); // Vector de inicialización
final encrypter = encrypt.Encrypter(encrypt.AES(key));

class AddBankAccountScreen extends ConsumerWidget {
  const AddBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // Restrict access to providers only
    if (accountType != AccountType.independentProvider &&
        accountType != AccountType.corporateProvider) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Bank Account')),
        body: const Center(
          child: Text('Access restricted to providers only.'),
        ),
      );
    }

    final formKey = GlobalKey<FormState>();
    final accountHolderNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final routingNumberController = TextEditingController();
    final accountTypeController = TextEditingController();
    String? _selectedBank; // Banco seleccionado
    bool _isLoading = false;

    Future<List<String>> fetchBanks() async {
      final snapshot =
          await FirebaseFirestore.instance.collection('banks').get();
      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    }

    Future<void> addBankAccount() async {
      if (!formKey.currentState!.validate()) return;

      try {
        // Obtener la información del usuario autenticado
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("No user is logged in.");
        }
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw Exception("User email not found.");
        }

        // Cifrar datos confidenciales
        final encryptedAccountNumber =
            encrypter.encrypt(accountNumberController.text, iv: iv).base64;
        final encryptedRoutingNumber =
            encrypter.encrypt(routingNumberController.text, iv: iv).base64;

        // Guardar en Firebase
        final bankAccountData = {
          'user_id': user.uid,
          'email': email,
          'bank_name': _selectedBank, // Nombre del banco seleccionado
          'account_holder_name': accountHolderNameController.text,
          'account_number': encryptedAccountNumber,
          'routing_number': encryptedRoutingNumber,
          'account_type': accountTypeController.text, // Checking o Savings
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('bank_accounts')
            .doc()
            .set(bankAccountData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
          'Bank Account Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchBanks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final banks = snapshot.data ?? [];
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: banks.map((bank) {
                          return DropdownMenuItem(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _selectedBank = value;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a bank'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: accountHolderNameController,
                        decoration: InputDecoration(
                          labelText: 'Account Holder Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter the account holder\'s name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: routingNumberController,
                              decoration: InputDecoration(
                                labelText: 'Routing Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter routing number'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: accountNumberController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter account number'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Account Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Checking', child: Text('Checking')),
                          DropdownMenuItem(
                              value: 'Savings', child: Text('Savings')),
                        ],
                        onChanged: (value) {
                          accountTypeController.text = value ?? '';
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select account type'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : addBankAccount,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Bank Account',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
