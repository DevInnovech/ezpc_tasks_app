// payment_provider.dart
import 'package:ezpc_tasks_app/features/payments%20setings/data/mock_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/bank_account_model.dart';

// Mock mode toggle
const bool isMockMode = true;

// Providers for card and bank account lists
final cardListProvider = StateProvider<List<CardModel>>(
    (ref) => isMockMode ? mockCards : mockCards // Use mock data if in mock mode
    );

final bankAccountListProvider = StateProvider<List<BankAccountModel>>((ref) =>
        isMockMode
            ? mockBankAccounts
            : mockBankAccounts // Use mock data if in mock mode
    );

// Filter methods to differentiate between clients and providers
final clientCardsProvider = Provider<List<CardModel>>((ref) {
  final cards = ref.watch(cardListProvider);
  return cards.where((card) => card.ownerType == 'client').toList();
});

final providerCardsProvider = Provider<List<CardModel>>((ref) {
  final cards = ref.watch(cardListProvider);
  return cards.where((card) => card.ownerType == 'provider').toList();
});

final clientBankAccountsProvider = Provider<List<BankAccountModel>>((ref) {
  final accounts = ref.watch(bankAccountListProvider);
  return accounts.where((account) => account.ownerType == 'client').toList();
});

final providerBankAccountsProvider = Provider<List<BankAccountModel>>((ref) {
  final accounts = ref.watch(bankAccountListProvider);
  return accounts.where((account) => account.ownerType == 'provider').toList();
});
