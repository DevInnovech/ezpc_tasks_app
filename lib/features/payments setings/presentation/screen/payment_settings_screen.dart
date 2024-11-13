// payment_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import 'add_bank_account_screen.dart';
import 'edit_bank_account_screen.dart';
import '../../data/payment_provider.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class PaymentSettingsScreen extends ConsumerWidget {
  const PaymentSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);
    final bankAccounts = ref.watch(bankAccountListProvider);
    final accountType = ref.watch(accountTypeProvider);
    print(accountType);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Cards',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (accountType == AccountType.client ||
              accountType == AccountType.independentProvider)
            ...cards.map((card) => ListTile(
                  title: Text('**** ${card.last4} (${card.brand})'),
                  subtitle: Text('Exp: ${card.expMonth}/${card.expYear}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCardScreen(card: card),
                      ),
                    ),
                  ),
                )),
          if (accountType == AccountType.client ||
              accountType == AccountType.independentProvider)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCardScreen(),
                ),
              ),
              child: const Text('Add Card'),
            ),
          const SizedBox(height: 20),
          const Text('Bank Accounts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (accountType == AccountType.independentProvider ||
              accountType == AccountType.corporateProvider)
            ...bankAccounts.map((account) => ListTile(
                  title: Text(
                      '${account.bankName} (**** ${account.accountNumber})'),
                  subtitle: Text('Holder: ${account.accountHolderName}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditBankAccountScreen(account: account),
                      ),
                    ),
                  ),
                )),
          if (accountType == AccountType.independentProvider ||
              accountType == AccountType.corporateProvider)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddBankAccountScreen(),
                ),
              ),
              child: const Text('Add Bank Account'),
            ),
          const SizedBox(height: 20),
          if (accountType == AccountType.client) ...[
            const Text('Client Specific Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Additional client-specific options
          ] else if (accountType == AccountType.independentProvider ||
              accountType == AccountType.corporateProvider) ...[
            const Text('Provider Specific Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Additional provider-specific options
          ],
        ],
      ),
    );
  }
}
