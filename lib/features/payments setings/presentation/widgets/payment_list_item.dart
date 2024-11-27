// payment_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_model.dart';
import '../../models/bank_account_model.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class PaymentListItem extends ConsumerWidget {
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentListItem({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    final isCard = item is CardModel;
    final isBankAccount = item is BankAccountModel;

    // Restrict delete action to providers for bank accounts
    final canDelete = (isCard &&
            (accountType == AccountType.client ||
                accountType == AccountType.independentProvider)) ||
        (isBankAccount &&
            (accountType == AccountType.independentProvider ||
                accountType == AccountType.corporateProvider));

    return ListTile(
      leading: Icon(isCard ? Icons.credit_card : Icons.account_balance),
      title: Text(isCard
          ? '**** ${item.accountNumber} (${item.brand})'
          : '${item.bankName} (**** ${item.accountNumber})'),
      subtitle: isCard
          ? Text('Exp: ${item.expMonth}/${item.expYear}')
          : Text('Holder: ${item.accountHolderName}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
