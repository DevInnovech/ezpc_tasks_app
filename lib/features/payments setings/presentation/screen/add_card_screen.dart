// add_card_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/stripe_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class AddCardScreen extends ConsumerWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // Restrict access to clients and providers only
    if (accountType != AccountType.client &&
        accountType != AccountType.independentProvider) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Card')),
        body: const Center(
          child: Text('Access restricted to clients and providers only.'),
        ),
      );
    }

    final _formKey = GlobalKey<FormState>();
    final _cardNumberController = TextEditingController();
    final _expMonthController = TextEditingController();
    final _expYearController = TextEditingController();
    final _cvcController = TextEditingController();

    Future<void> _addCard() async {
      if (_formKey.currentState!.validate()) {
        final result = await StripeService.instance.addCard(
          cardNumber: _cardNumberController.text,
          expMonth: _expMonthController.text,
          expYear: _expYearController.text,
          cvc: _cvcController.text,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card added successfully!')),
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
      appBar: AppBar(title: const Text('Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the card number'
                    : null,
              ),
              TextFormField(
                controller: _expMonthController,
                decoration:
                    const InputDecoration(labelText: 'Expiration Month'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the expiration month'
                    : null,
              ),
              TextFormField(
                controller: _expYearController,
                decoration: const InputDecoration(labelText: 'Expiration Year'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the expiration year'
                    : null,
              ),
              TextFormField(
                controller: _cvcController,
                decoration: const InputDecoration(labelText: 'CVC'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the CVC'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCard,
                child: const Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
