// mock_stripe_service.dart

import 'package:ezpc_tasks_app/features/payments%20setings/data/payment_provider.dart';

class MockStripeService implements StripeBaseService {
  static final MockStripeService instance = MockStripeService._internal();

  MockStripeService._internal();

  void initialize(String publishableKey) {
    // Simulate Stripe initialization
    print("Mock Stripe initialized with publishableKey: \$publishableKey");
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    // Simulated response for PaymentIntent creation
    return Future.delayed(
      const Duration(seconds: 1),
      () => {
        "id": "mock_payment_intent_id",
        "client_secret": "mock_client_secret",
        "amount": amount,
        "currency": currency,
      },
    );
  }

  Future<void> confirmPayment(
      String clientSecret, String paymentMethodId) async {
    // Simulated confirmation logic
    return Future.delayed(const Duration(milliseconds: 500), () {
      print("Payment confirmed for clientSecret: \$clientSecret");
    });
  }

  Future<Map<String, dynamic>> addCard({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    // Simulate adding a card
    return Future.delayed(
      const Duration(seconds: 1),
      () => {
        "success": true,
        "token": "mock_card_token",
      },
    );
  }

  @override
  Future<Map<String, dynamic>> deleteCard(String cardId) async {
    // Simulate card deletion
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => {
        "success": true,
        "message": "Card deleted successfully",
      },
    );
  }

  Future<Map<String, dynamic>> addBankAccount({
    required String accountHolderName,
    required String accountNumber,
    required String routingNumber,
    required String bankName,
  }) async {
    // Simulate adding a bank account
    return Future.delayed(
      const Duration(seconds: 1),
      () => {
        "success": true,
        "message": "Bank account added successfully",
      },
    );
  }

  @override
  Future<Map<String, dynamic>> deleteBankAccount(String bankAccountId) async {
    // Simulate bank account deletion
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => {
        "success": true,
        "message": "Bank account deleted successfully",
      },
    );
  }
}
