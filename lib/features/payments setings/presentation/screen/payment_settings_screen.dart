import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import 'add_bank_account_screen.dart';
import 'edit_bank_account_screen.dart';
import '../../data/payment_provider.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);

class PaymentSettingsScreen extends ConsumerWidget {
  const PaymentSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListNotifierProvider);
    final bankAccounts = ref.watch(bankAccountListNotifierProvider);
    final accountType = ref.watch(accountTypeProvider);

    return Scaffold(
        appBar: AppBar(title: const Text('Payment Settings')),
        body: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Pay with',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (accountType == AccountType.client ||
                    accountType == AccountType.independentProvider)
                  ...cards.map((card) => _buildPaymentMethodTile(
                        context,
                        ref,
                        methodId: card.id,
                        title: '**** ${card.last4}',
                        subtitle: '${card.brand}',
                        icon: Icons.credit_card,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCardScreen(card: card),
                          ),
                        ),
                        onDelete: () {
                          ref
                              .read(cardListNotifierProvider.notifier)
                              .deleteCard(card.id);
                        },
                      )),
                if (accountType == AccountType.independentProvider ||
                    accountType == AccountType.corporateProvider)
                  ...bankAccounts.map((account) => _buildPaymentMethodTile(
                        context,
                        ref,
                        methodId: account.id,
                        title: '${account.bankName}',
                        subtitle: '**** ${account.accountNumber}',
                        icon: Icons.account_balance,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditBankAccountScreen(account: account),
                          ),
                        ),
                        onDelete: () {
                          ref
                              .read(bankAccountListNotifierProvider.notifier)
                              .deleteAccount(account.id);
                        },
                      )),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADD PAYMENT METHOD',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (accountType == AccountType.client ||
                    accountType == AccountType.independentProvider)
                  _buildCustomButton(
                    context,
                    icon: Icons.credit_card,
                    label: 'Credit or debit card',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCardScreen(),
                      ),
                    ),
                  ),
                if (accountType == AccountType.independentProvider ||
                    accountType == AccountType.corporateProvider)
                  _buildCustomButton(
                    context,
                    icon: Icons.account_balance,
                    label: 'Bank Account',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBankAccountScreen(),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ]));
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    WidgetRef ref, {
    required String methodId,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);

    return Slidable(
      key: ValueKey(methodId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: selectedPaymentMethod == methodId
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          ref.read(selectedPaymentMethodProvider.notifier).state = methodId;
        },
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.grey, width: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
