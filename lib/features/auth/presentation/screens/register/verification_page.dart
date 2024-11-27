import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/verfication_selector.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationSelectionScreen extends ConsumerStatefulWidget {
  const VerificationSelectionScreen({super.key});

  @override
  _VerificationSelectionScreenState createState() =>
      _VerificationSelectionScreenState();
}

class _VerificationSelectionScreenState
    extends ConsumerState<VerificationSelectionScreen> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Select which option should be used to reset your password.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24.0),
            VerificationOptionSelector(
              title: 'Via sms:',
              description: '+1 *** *** 1234',
              icon: Icons.phone_android,
              isSelected: selectedOption == 'sms',
              onTap: () {
                setState(() {
                  selectedOption = 'sms';
                });
              },
            ),
            Utils.verticalSpace(10.0),
            VerificationOptionSelector(
              title: 'Via Email:',
              description: '******oe@email.com',
              icon: Icons.email_outlined,
              isSelected: selectedOption == 'email',
              onTap: () {
                setState(() {
                  selectedOption = 'email';
                });
              },
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: selectedOption == null
                  ? null
                  : () {
                      if (selectedOption == 'sms') {
                        // Aquí podrías almacenar la selección en el estado global si es necesario
                        // Navegar a la siguiente pantalla
                        Navigator.pushNamed(
                          context,
                          RouteNames
                              .verificationCodeScreen, // Reemplazar por la ruta deseada
                        );
                      } else if (selectedOption == 'email') {
                        // Aquí podrías almacenar la selección en el estado global si es necesario
                        // Navegar a la siguiente pantalla
                        // se le mada e codigo por correo
                        Navigator.pushNamed(
                          context,
                          RouteNames
                              .verificationCodeScreen, // Reemplazar por la ruta deseada
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
