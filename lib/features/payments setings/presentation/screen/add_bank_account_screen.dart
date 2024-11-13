// add_bank_account_screen.dart
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
    final _routingNumberController = TextEditingController();
    final _bankNameController = TextEditingController();

    Future<void> _addBankAccount() async {
      if (_formKey.currentState!.validate()) {
        final result = await StripeService.instance.addBankAccount(
          accountHolderName: _accountHolderNameController.text,
          accountNumber: _accountNumberController.text,
          routingNumber: _routingNumberController.text,
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
      appBar: AppBar(title: const Text('Add Bank Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountHolderNameController,
                decoration:
                    const InputDecoration(labelText: 'Account Holder Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the account holder name'
                    : null,
              ),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the account number'
                    : null,
              ),
              TextFormField(
                controller: _routingNumberController,
                decoration: const InputDecoration(labelText: 'Routing Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the routing number'
                    : null,
              ),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the bank name'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBankAccount,
                child: const Text('Add Bank Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
