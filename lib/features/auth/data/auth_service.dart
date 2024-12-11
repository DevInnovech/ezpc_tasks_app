import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Para generar el número aleatorio

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para generar un código único con prefijo basado en el rol y 6 dígitos
  String generateUniqueCode(String role) {
    final random = Random();
    final code = List<int>.generate(6, (_) => random.nextInt(10))
        .join(); // Genera 6 dígitos aleatorios
    if (role == 'Client') {
      return 'CLI$code'; // Código para clientes
    } else if (role == 'Independent Provider') {
      return 'PRO$code'; // Código para proveedores independientes
    }
    return 'USR$code'; // Código genérico si el tipo de cuenta no es válido
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

  // Obtener el rol del usuario desde Firestore
  Future<String?> getUserRole(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data()!.containsKey('accountType')) {
        return userDoc.get('accountType');
      } else {
        print('User role not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  // Registro de cliente o proveedor
  Future<User?> SignUpMethod({
    required String email,
    required String name,
    required String lastName,
    required String phoneNumber,
    required String username,
    required String password,
    required String role, // Tipo de cuenta: Client o Independent Provider
    required String description, // Descripción
    required String address, // Dirección
    required String communicationPreference, // Preferencia de comunicación
    required int experienceYears, // Años de experiencia (solo para proveedor)
    required String languages, // Idiomas
    required String preferredPaymentMethod, // Método de pago preferido
    required String profileImageUrl,
    required String accountType, // URL de imagen de perfil
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
        // Generar el código único basado en el rol
        String uniqueCode = generateUniqueCode(role);

        // Guardar información en la colección `users`
        await _firestore.collection('users').doc(user.uid).set({
          'accountType': role, // AccountType es igual al role
          'role': role,
          'email': email,
          'status': 'Pending', // Estado inicial
          'userID': uniqueCode,
          'name': name,
          'lastName': lastName,
        });

        // Guardar información en la colección correspondiente (`clients` o `providers`)
        if (role == 'Client') {
          await _firestore.collection('clients').doc(user.uid).set({
            'name': name,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'address': address,
            'description': description,
            'communicationPreference': communicationPreference,
            'preferredPaymentMethod': preferredPaymentMethod,
            'profileImageUrl': profileImageUrl,
            'email': email,
            'userID': uniqueCode,
            'createdAt': FieldValue.serverTimestamp(),
            'acceptedTerms': true,
          });
        } else if (role == 'Independent Provider') {
          await _firestore.collection('providers').doc(user.uid).set({
            'name': name,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'address': address,
            'description': description,
            'communicationPreference': communicationPreference,
            'experienceYears': experienceYears,
            'languages': languages,
            'preferredPaymentMethod': preferredPaymentMethod,
            'profileImageUrl': profileImageUrl,
            'email': email,
            'userID': uniqueCode,
            'createdAt': FieldValue.serverTimestamp(),
            'acceptedTerms': true,
          });
        }

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
}
