import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ResetOptionSelectionScreen extends StatefulWidget {
  const ResetOptionSelectionScreen({super.key});

  @override
  _ResetOptionSelectionScreenState createState() =>
      _ResetOptionSelectionScreenState();
}

class _ResetOptionSelectionScreenState
    extends State<ResetOptionSelectionScreen> {
  String? selectedOption; // Almacena la opción seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón de volver
            IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10.0),
            const CustomText(
              text: 'Forgot Password',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8.0),
            const CustomText(
              text:
                  'Select which option should be used to reset your password.',
              fontSize: 16.0,
            ),
            const SizedBox(height: 30.0),
            InkWell(
              onTap: () {
                setState(() {
                  selectedOption = 'sms';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: selectedOption == 'sms'
                      ? Colors.grey[200]
                      : Colors.white, // Indicar selección
                  border: Border.all(
                      color:
                          selectedOption == 'sms' ? primaryColor : Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_android, color: primaryColor),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Via sms:',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: '+1 *** *** 1234',
                          fontSize: 14.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                setState(() {
                  selectedOption = 'email';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: selectedOption == 'email'
                      ? Colors.grey[200]
                      : Colors.white, // Indicar selección
                  border: Border.all(
                      color: selectedOption == 'email'
                          ? primaryColor
                          : Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.email, color: primaryColor),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Via Email:',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: '****oe@email.com',
                          fontSize: 14.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: selectedOption == null
                  ? null // Deshabilitar si no se selecciona ninguna opción
                  : () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.forgotPasswordScreen,
                        arguments:
                            selectedOption, // Enviar argumento seleccionado
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
