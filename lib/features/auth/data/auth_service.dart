import 'package:ezpc_tasks_app/features/auth/models/users_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para generar el número aleatorio

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para generar un código único con prefijo "EZPC" y 6 dígitos
  String generateUniqueCode() {
    final random = Random();
    final code = List<int>.generate(6, (_) => random.nextInt(10)).join();
    return 'EZPC$code';
  }

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

  // Registro como Independent Provider utilizando UserModel
  Future<User?> signUpUser({
    required String email,
    required String name,
    required String lastName,
    required String phoneNumber,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Generar el código único
        String uniqueCode = generateUniqueCode();

        // Crear instancia de UserModel con la información del usuario
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          lastName: lastName,
          phoneNumber: phoneNumber,
          username: username,
          role: role,
          uniqueCode: uniqueCode,
          country: '', // Placeholder, si no se obtiene información de país
          state: '', // Placeholder, si no se obtiene información de estado
          address: '', // Placeholder, si no se obtiene dirección
        );

        // Guardar información adicional en Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return user;
      }
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
    return null;
  }

  // Obtener el rol del usuario desde Firestore
  Future<String?> getUserRole(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data()!.containsKey('role')) {
        return userDoc.get('role');
      } else {
        print('User role not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
