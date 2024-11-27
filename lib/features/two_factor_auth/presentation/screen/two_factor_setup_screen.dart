import 'package:ezpc_tasks_app/features/two_factor_auth/data/two_factor_provider.dart';
import 'package:ezpc_tasks_app/features/two_factor_auth/presentation/screen/verification_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TwoFactorSetupScreen extends ConsumerWidget {
  final Color textColor = primaryColor;

  const TwoFactorSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set up 2 Factor Authentication',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMS Authentication',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'A security code will be sent via text message.',
                    style: TextStyle(color: textColor),
                  ),
                ),
                CupertinoSwitch(
                  value: ref.watch(authMethodProvider) == 'SMS',
                  onChanged: (value) {
                    if (value) {
                      // Activar SMS y navegar a la pantalla de verificación
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(authMethod: 'SMS'),
                        ),
                      );
                    } else {
                      // Desactivar SMS
                      ref.read(authMethodProvider.notifier).state = '';
                    }
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Authentication app (Recommended)',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'The app will provide unique codes for you to log in with anytime.',
                    style: TextStyle(color: textColor),
                  ),
                ),
                CupertinoSwitch(
                  value: ref.watch(authMethodProvider) == 'App',
                  onChanged: (value) {
                    if (value) {
                      // Activar la autenticación por aplicación y navegar a la pantalla de verificación
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(authMethod: 'App'),
                        ),
                      );
                    } else {
                      // Desactivar la autenticación por aplicación
                      ref.read(authMethodProvider.notifier).state = '';
                    }
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
