import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/auth/data/auth_service.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({super.key});

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    try {
      Map<String, String?> preferences = await _authService.loadPreferences();
      String? email = preferences['email'];
      String? password = preferences['password'];
      if (email != null && password != null) {
        UserCredential? userCredential =
            await _authService.signInWithEmailAndPassword(email, password);

        if (userCredential != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            final userRole = userDoc.get('accountType');
            final userStatus = userDoc.get('status');

            if (userStatus == 'Approved') {
              _navigateToRoleBasedScreen(userRole);
            } else if (userStatus == 'Pending') {
              Navigator.pushNamed(
                  context, RouteNames.accountVerificationScreen);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Your account is not active. Contact support.')),
              );
              _redirectToLogin();
            }
          } else {
            _redirectToLogin();
          }
        } else {
          _redirectToLogin();
        }
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      print('Auto-login failed: $e');
      _redirectToLogin();
    }
  }

  void _navigateToRoleBasedScreen(String userRole) {
    if (userRole == 'Client') {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.ClientmainScreen, (route) => false);
    } else if (userRole == 'Independent Provider') {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.mainScreen, (route) => false);
    } else if (userRole == 'Corporate Provider') {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.mainScreen, (route) => false);
    } else if (userRole == 'Employee Provider') {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.mainScreen, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unrecognized role.')),
      );
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Navigator.pushNamedAndRemoveUntil(
        context, RouteNames.authenticationScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
