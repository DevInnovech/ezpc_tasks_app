import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
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

    final _formKey = GlobalKey<FormState>();
    final _accountHolderNameController =
        TextEditingController(text: account.accountHolderName);
    final _accountNumberController =
        TextEditingController(text: account.accountNumber);
    final _branchCodeController =
        TextEditingController(text: account.branchCode);
    final _bankNameController = TextEditingController(text: account.bankName);

    Future<void> _saveBankAccount() async {
      if (_formKey.currentState!.validate()) {
        // Logic to update the bank account details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account updated successfully!')),
        );
        Navigator.pop(context);
      }
    }

    Future<void> _removeBankAccount() async {
      final result = await StripeService.instance.deleteBankAccount(account.id);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account removed successfully!')),
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
          'Edit or Remove Bank Account',
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
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: 'Bank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the bank name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountHolderNameController,
                  decoration: InputDecoration(
                    labelText: 'Account Holder Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the account holder name'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _branchCodeController,
                        decoration: InputDecoration(
                          labelText: 'Branch Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter branch code'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _accountNumberController,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter account number'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveBankAccount,
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
                    onPressed: _removeBankAccount,
                    child: const Text(
                      'Remove Bank Account',
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
