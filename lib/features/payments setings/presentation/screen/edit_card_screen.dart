// edit_card_screen.dart
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

    Future<void> _deleteCard() async {
      final result = await StripeService.instance.deleteCard(card.id);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit or Remove Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card Brand: ${card.brand}',
                style: const TextStyle(fontSize: 18)),
            Text('Card Number: ****${card.last4}',
                style: const TextStyle(fontSize: 18)),
            Text('Expiration Date: ${card.expMonth}/${card.expYear}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteCard,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Card'),
            ),
          ],
        ),
      ),
    );
  }
}
