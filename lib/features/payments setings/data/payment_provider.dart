import 'package:ezpc_tasks_app/features/payments%20setings/data/mock_data.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/utils/mock_stripe_service.dart';
import 'package:ezpc_tasks_app/features/payments%20setings/utils/stripe_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/bank_account_model.dart';

// Common interface for the services
abstract class StripeBaseService {
  Future<Map<String, dynamic>> deleteCard(String cardId);
  Future<Map<String, dynamic>> deleteBankAccount(String bankAccountId);
}

// Mock mode toggle
const bool isMockMode = true;
final StripeBaseService stripeService =
    isMockMode ? MockStripeService.instance : StripeService.instance;

// Card List Notifier
class CardListNotifier extends StateNotifier<List<CardModel>> {
  CardListNotifier() : super(isMockMode ? mockCards : []);

  Future<void> deleteCard(String cardId) async {
    final response = await stripeService.deleteCard(cardId);
    if (response['success'] == true) {
      state = state.where((card) => card.id != cardId).toList();
    } else {
      throw Exception('Failed to delete card: ${response['message']}');
    }
  }
}

// Bank Account List Notifier
class BankAccountListNotifier extends StateNotifier<List<BankAccountModel>> {
  BankAccountListNotifier() : super(isMockMode ? mockBankAccounts : []);

  Future<void> deleteAccount(String accountId) async {
    final response = await stripeService.deleteBankAccount(accountId);
    if (response['success'] == true) {
      state = state.where((account) => account.id != accountId).toList();
    } else {
      throw Exception('Failed to delete bank account: ${response['message']}');
    }
  }
}

// Providers for Card and Bank Account List Notifiers
final cardListNotifierProvider =
    StateNotifierProvider<CardListNotifier, List<CardModel>>(
        (ref) => CardListNotifier());

final bankAccountListNotifierProvider =
    StateNotifierProvider<BankAccountListNotifier, List<BankAccountModel>>(
        (ref) => BankAccountListNotifier());
