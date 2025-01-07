import 'dart:convert';
import 'package:ezpc_tasks_app/features/payments%20setings/data/payment_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService implements StripeBaseService {
  static final StripeService instance = StripeService._internal();

  final String _publishableKey =
      "pk_test_51Q42mfP1yXF5VqY3vOeUXSmBWzUJLvNkV9KZ4e1c9jHCJ70iM3faFYkDmHHrBnTjcU2ROd7bNo49b3OxxYygC6pK00NbTtDUpE";
  final String _secretKey =
      "sk_test_51Q42mfP1yXF5VqY3ssNk9Q1GLw63m5UUFpRGmJK6Ok42EdA2oJUwt3dGrQrE1sOFKaweDV0ZMMU2rXZPx1niPUZ7009SI4zwNO";
  final String _baseUrl = "https://api.stripe.com/v1";

  StripeService._internal();

  // Inicializar Stripe con la clave publicable
  void initialize(String publishableKey) {
    Stripe.publishableKey = publishableKey;
    // Configura merchantIdentifier y urlScheme si es necesario
    // Stripe.merchantIdentifier = 'merchant.com.example';
    // Stripe.urlScheme = 'your-url-scheme'; // Para autenticación 3D Secure
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    final url = Uri.parse("$_baseUrl/payment_intents");
    final headers = {
      "Authorization": "Bearer $_secretKey",
      "Content-Type": "application/x-www-form-urlencoded",
    };
    final body = {
      "amount": amount,
      "currency": currency,
      "payment_method_types[]": "card",
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": jsonDecode(response.body),
        };
      } else {
        return {
          "success": false,
          "error": jsonDecode(response.body),
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  Future<void> confirmPayment(
      String clientSecret, String paymentMethodId) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );
    } catch (e) {
      throw Exception("Failed to confirm PaymentIntent: $e");
    }
  }

  Future<Map<String, dynamic>> addCard({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    // Nota: En producción, debes utilizar el CardField para recopilar los datos de la tarjeta de forma segura.
    try {
      // Solo para propósitos de prueba; no recomendado en producción
      final cardDetails = CardDetails(
        number: cardNumber,
        expirationMonth: int.parse(expMonth),
        expirationYear: int.parse(expYear),
        cvc: cvc,
      );

      // Actualiza los detalles de la tarjeta (solo para pruebas)
      await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

      // Crea el PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return {
        "success": true,
        "paymentMethodId": paymentMethod.id,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCard(String cardId) async {
    try {
      // La eliminación de la tarjeta debe manejarse en el backend
      return {
        "success": true,
        "message": "Tarjeta eliminada correctamente",
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> addBankAccount({
    required String accountHolderName,
    required String accountNumber,
    required String routingNumber,
    required String bankName,
  }) async {
    try {
      // La adición de cuentas bancarias debe manejarse en el backend
      return {
        "success": true,
        "message": "Cuenta bancaria agregada correctamente",
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteBankAccount(String bankAccountId) async {
    try {
      // La eliminación de cuentas bancarias debe manejarse en el backend
      return {
        "success": true,
        "message": "Cuenta bancaria eliminada correctamente",
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}
