import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicio de sesión con correo electrónico y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación
      // Puedes mostrar un mensaje de error al usuario o lanzar una excepción personalizada
      print('Login error: ${e.message}');
      return null;
    }
  }

  // Guardar preferencias (email y contraseña si 'isRemember' es true)
  Future<void> savePreferences(
      String email, String password, bool isRemember) async {
    final prefs = await SharedPreferences.getInstance();
    if (isRemember) {
      await prefs.setString('email', email);
      await prefs.setString('password',
          password); // Considera cifrar la contraseña si es necesario
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }
}
