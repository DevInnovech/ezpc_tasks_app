// edit_bank_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bank_account_model.dart';
import '../../utils/stripe_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class EditBankAccountScreen extends ConsumerWidget {
  final BankAccountModel account;

  const EditBankAccountScreen({Key? key, required this.account})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // Restrict access to providers only
    if (accountType != AccountType.independentProvider &&
        accountType != AccountType.corporateProvider) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Bank Account')),
        body: const Center(
          child: Text('Access restricted to providers only.'),
        ),
      );
    }

    Future<void> _deleteBankAccount() async {
      final result = await StripeService.instance.deleteBankAccount(account.id);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account deleted successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit or Remove Bank Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank Name: ${account.bankName}',
                style: const TextStyle(fontSize: 18)),
            Text('Account Number: ****${account.accountNumber}',
                style: const TextStyle(fontSize: 18)),
            Text('Account Holder: ${account.accountHolderName}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteBankAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Bank Account'),
            ),
          ],
        ),
      ),
    );
  }
}
