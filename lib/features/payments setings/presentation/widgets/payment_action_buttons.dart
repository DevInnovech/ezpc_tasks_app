// payment_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';

class PaymentActionButtons extends ConsumerWidget {
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentActionButtons({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountType = ref.watch(accountTypeProvider);

    // Buttons visibility based on account type
    final canAdd = accountType == AccountType.client ||
        accountType == AccountType.independentProvider;
    final canEdit = accountType == AccountType.client ||
        accountType == AccountType.independentProvider;
    final canDelete = accountType == AccountType.independentProvider ||
        accountType == AccountType.corporateProvider;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (canAdd)
          ElevatedButton(
            onPressed: onAdd,
            child: const Text('Add'),
          ),
        if (canEdit)
          ElevatedButton(
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
        if (canDelete)
          ElevatedButton(
            onPressed: onDelete,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
      ],
    );
  }
}
