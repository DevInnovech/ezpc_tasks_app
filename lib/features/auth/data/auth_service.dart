import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Registro como Independent Provider
  Future<User?> SignUpMethod({
    required String email,
    required String name,
    required String lastName,
    //   required DateTime dob,
    required String phoneNumber,
    required String username,
    required String password,
    required String role, // Agregar parámetro para rol
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
        // Guardar información adicional en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'lastName': lastName,
          //         'dob': dob,
          'phoneNumber': phoneNumber,
          'role': role, // Guardar el rol obtenido
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de Firebase Auth
      print('Error: ${e.message}');
      return null;
    } catch (e) {
      // Manejo de errores generales
      print('Error: $e');
      return null;
    }
    return null;
  }

  Future<String?> getUserRole(User user) async {
    try {
      // Get a reference to the user document in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the document exists and has a 'role' field
      if (userDoc.exists && userDoc.data()!.containsKey('role')) {
        return userDoc.get('role');
      } else {
        // Handle the case where the role is not found
        print('User role not found in Firestore');
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the Firestore query
      print('Error fetching user role: $e');
      return null;
    }
  }
}
