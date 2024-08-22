import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountType {
  client,
  independentProvider,
  corporateProvider,
  employeeProvider,
}

class AccountTypeNotifier extends StateNotifier<AccountType?> {
  AccountTypeNotifier() : super(null);

  void selectAccountType(AccountType type) {
    state = type;
  }
}

final accountTypeProvider =
    StateNotifierProvider<AccountTypeNotifier, AccountType?>((ref) {
  return AccountTypeNotifier();
});
