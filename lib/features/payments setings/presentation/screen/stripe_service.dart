import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _firebaseFunctionsBaseUrl =
      'https://stripepaymentintentrequest-kdtiuzlqjq-uc.a.run.app';

  // Método para procesar pagos
  static Future<bool> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    required String currency,
    required double amount,
  }) async {
    try {
      // Validar y dividir la fecha de vencimiento en mes y año
      final expiryParts = expiryDate.split('/');
      if (expiryParts.length != 2) {
        throw 'Invalid expiry date format. Use MM/YY.';
      }
      final String expMonth = expiryParts[0];
      final String expYear = '20${expiryParts[1]}';

      final response = await http.post(
        Uri.parse('$_firebaseFunctionsBaseUrl/process-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cardNumber': cardNumber,
          'expMonth': expMonth,
          'expYear': expYear,
          'cvv': cvv,
          'cardHolderName': cardHolderName,
          'amount': (amount * 100).toInt(), // En centavos
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        throw Exception('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      print('StripeService Error: $e');
      rethrow;
    }
  }

  // Método para agregar una tarjeta a un cliente
  static Future<Map<String, dynamic>> addCard({
    required String email,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvv,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_firebaseFunctionsBaseUrl/add-card'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'cardNumber': cardNumber,
          'expMonth': expMonth,
          'expYear': expYear,
          'cvv': cvv,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'card': responseData['card'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
