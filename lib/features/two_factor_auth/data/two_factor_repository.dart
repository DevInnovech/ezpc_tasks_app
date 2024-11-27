import 'package:flutter_riverpod/flutter_riverpod.dart';

class TwoFactorRepository {
  // Simulación de envío de código (Firebase integración futura)
  Future<void> sendVerificationCode(String method) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulación de envío
  }

  // Simulación de verificación de código
  Future<bool> verifyCode(String code) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulación de verificación
    return code == "123456"; // Simula éxito si el código es 123456
  }
}

final twoFactorRepositoryProvider = Provider((ref) => TwoFactorRepository());
