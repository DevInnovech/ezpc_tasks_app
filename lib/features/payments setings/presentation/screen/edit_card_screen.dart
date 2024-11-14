import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_model.dart';
import '../../utils/stripe_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class EditCardScreen extends ConsumerWidget {
  final CardModel card;

  const EditCardScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // Restrict access to clients and providers only
    if (accountType != AccountType.client &&
        accountType != AccountType.independentProvider) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Card')),
        body: const Center(
          child: Text('Access restricted to clients and providers only.'),
        ),
      );
    }

    final _formKey = GlobalKey<FormState>();
    final _cardNumberController =
        TextEditingController(text: '#### #### #### ${card.last4}');
    final _expMonthController =
        TextEditingController(text: card.expMonth.toString());
    final _expYearController =
        TextEditingController(text: card.expYear.toString());
    final _cvcController = TextEditingController();
    final _zipCodeController = TextEditingController(text: card.zipCode ?? '');
    final _nameController = TextEditingController(text: card.cardHolderName);

    Future<void> _saveCard() async {
      if (_formKey.currentState!.validate()) {
        // Logic to update the card details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully!')),
        );
        Navigator.pop(context);
      }
    }

    Future<void> _removeCard() async {
      final result = await StripeService.instance.deleteCard(card.id);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card removed successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
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
          'Edit or Remove Card',
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
                    fillColor: Colors.grey[200],
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expMonthController,
                        decoration: InputDecoration(
                          labelText: 'Expiration Month',
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
                        controller: _expYearController,
                        decoration: InputDecoration(
                          labelText: 'Expiration Year',
                          hintText: 'YYYY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter expiration year'
                            : null,
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Titular Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the cardholder name'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _removeCard,
                    child: const Text(
                      'Remove Card',
                      style: TextStyle(color: Colors.red, fontSize: 16),
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
