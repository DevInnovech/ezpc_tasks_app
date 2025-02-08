import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:io';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    // Definir los alcances necesarios para Firebase Cloud Messaging
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final file = File('config/service-account.json');
    final credentialsJson = jsonDecode(await file.readAsString());
    // Cargar las credenciales de la cuenta de servicio
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);

    // Autenticación con la cuenta de servicio
    final client = await clientViaServiceAccount(credentials, scopes);

    // Retornar el token de autenticación
    return client.credentials.accessToken.data;
  }
}
