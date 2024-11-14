import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
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
    final _zipCodeController = TextEditingController();
    final _countryController =
        TextEditingController(text: 'Dominican Republic');

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Card Details',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    prefixIcon:
                        Icon(Icons.credit_card, color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the card number'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expMonthController,
                        decoration: InputDecoration(
                          labelText: 'Expiration',
                          hintText: 'MM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter expiration month'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvcController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter CVC' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(
                    labelText: 'ZIP Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter ZIP Code'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Country/Region',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: primaryColor)),
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
