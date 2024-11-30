import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _apiBaseUrl = 'https://api.stripe.com/v1';
  static const String _apiKey =
      'sk_test_51Q42mfP1yXF5VqY3ssNk9Q1GLw63m5UUFpRGmJK6Ok42EdA2oJUwt3dGrQrE1sOFKaweDV0ZMMU2rXZPx1niPUZ7009SI4zwNO';

  static Future<bool> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    required double amount,
    required String currency,
  }) async {
    try {
      // Divide expiryDate into month and year
      final expiryParts = expiryDate.split('/');
      if (expiryParts.length != 2) {
        throw 'Invalid expiry date format. Use MM/YY.';
      }
      final String expMonth = expiryParts[0];
      final String expYear = '20${expiryParts[1]}';

      // Create a token with Stripe API
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/tokens'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'card[number]': cardNumber,
          'card[exp_month]': expMonth,
          'card[exp_year]': expYear,
          'card[cvc]': cvv,
          'card[name]': cardHolderName,
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['id'] != null) {
        final String token = responseData['id'];

        // Charge the customer
        final chargeResponse = await http.post(
          Uri.parse('$_apiBaseUrl/charges'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'amount': '5000', // Example amount in cents ($50.00)
            'currency': 'usd',
            'source': token,
            'description': 'Test Payment',
          },
        );

        return chargeResponse.statusCode == 200;
      } else {
        throw responseData['error']?['message'] ?? 'Failed to create token.';
      }
    } catch (e) {
      print('StripeService Error: $e');
      rethrow;
    }
  }
}
