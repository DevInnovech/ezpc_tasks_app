import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ResetOptionSelectionScreen extends StatelessWidget {
  const ResetOptionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Navigator.pushNamed(context, RouteNames.verificationCodeScreen);
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: primaryColor),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: 'Via sms:',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                        const CustomText(
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
                Navigator.pushNamed(context, RouteNames.forgotPasswordScreen,
                    arguments: 'email');
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: primaryColor),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: 'Via Email:',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                        const CustomText(
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
              onPressed: () {
                // Handle continue action, e.g., navigating to the selected option's screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
