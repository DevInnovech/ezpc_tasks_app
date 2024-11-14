import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/stripe_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class AddBankAccountScreen extends ConsumerWidget {
  const AddBankAccountScreen({Key? key}) : super(key: key);

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

    final _formKey = GlobalKey<FormState>();
    final _accountHolderNameController = TextEditingController();
    final _accountNumberController = TextEditingController();
    final _branchCodeController = TextEditingController();
    final _bankNameController = TextEditingController();

    Future<void> _addBankAccount() async {
      if (_formKey.currentState!.validate()) {
        final result = await StripeService.instance.addBankAccount(
          accountHolderName: _accountHolderNameController.text,
          accountNumber: _accountNumberController.text,
          routingNumber: _branchCodeController.text,
          bankName: _bankNameController.text,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank account added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Bank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    'Bank A',
                    'Bank B',
                    'Bank C',
                  ].map((bank) {
                    return DropdownMenuItem(
                      value: bank,
                      child: Text(bank),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _bankNameController.text = value ?? '';
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a bank'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountHolderNameController,
                  decoration: InputDecoration(
                    labelText: 'Account Holder Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the account holders name'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _branchCodeController,
                        decoration: InputDecoration(
                          labelText: 'Branch Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter branch code'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _accountNumberController,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter account number'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBankAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Add Bank Account',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
