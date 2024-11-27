import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simulamos que esta es la configuración de la aplicación que tiene la información del icono de la moneda
class AppSettings {
  final String currencyIcon;

  AppSettings({required this.currencyIcon});
}

// Creamos un provider para la configuración de la aplicación
final appSettingsProvider = Provider<AppSettings>((ref) {
  // Aquí deberías obtener la configuración real, por ejemplo desde una API, base de datos, etc.
  return AppSettings(currencyIcon: '\$');
});
