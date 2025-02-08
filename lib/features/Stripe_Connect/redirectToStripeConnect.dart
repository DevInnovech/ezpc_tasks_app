import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Función que crea una cuenta Express en Stripe y genera un enlace
/// para el proceso de onboarding en Stripe Connect.
///
/// **Nota:** En un entorno real, esta lógica debe estar en el backend.
Future<void> redirectToStripeConnect() async {
  // Tu secret test key (¡solo para pruebas!).
  const String stripeSecretKey =
      'sk_test_51Q42mfP1yXF5VqY3ssNk9Q1GLw63m5UUFpRGmJK6Ok42EdA2oJUwt3dGrQrE1sOFKaweDV0ZMMU2rXZPx1niPUZ7009SI4zwNO';

  const String firebaseFunctionUrl =
      'https://striperedirect-kdtiuzlqjq-uc.a.run.app';

  try {
    // 1. Crear una cuenta Connect de tipo Express.
    final accountResponse = await http.post(
      Uri.parse('https://api.stripe.com/v1/accounts'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'type': 'express',
      },
    );

    if (accountResponse.statusCode != 200) {
      print('Error al crear la cuenta: ${accountResponse.body}');
      return;
    }

    final accountData = jsonDecode(accountResponse.body);
    final String accountId = accountData['id'];
    print('Cuenta de Stripe creada: $accountId');

    // 2. Crear un enlace (account link) para el onboarding del proveedor.
    final accountLinkResponse = await http.post(
      Uri.parse('https://api.stripe.com/v1/account_links'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'account': accountId,
        // URL a la que se redirige si el usuario cancela el proceso.
        'refresh_url': '$firebaseFunctionUrl?type=reauth',
        // URL a la que se redirige después de completar el proceso.
        'return_url': '$firebaseFunctionUrl?type=return',
        'type': 'account_onboarding',
      },
    );

    if (accountLinkResponse.statusCode != 200) {
      print('Error al crear el enlace de cuenta: ${accountLinkResponse.body}');
      return;
    }

    final linkData = jsonDecode(accountLinkResponse.body);
    final String url = linkData['url'];
    print('Redirigiendo a: $url');

    // 3. Abrir la URL en el navegador.
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('No se pudo abrir la URL: $url');
    }
  } catch (e) {
    print('Excepción: $e');
  }
}
