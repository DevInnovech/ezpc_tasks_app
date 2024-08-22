import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Verification',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8.0),
            const CustomText(
              text:
                  'A 6-digit code was sent to your phone number OR email. Please enter the code to continue.',
              fontSize: 16.0,
            ),
            const SizedBox(height: 30.0),
            PinCodeTextField(
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                activeColor: primaryColor,
                selectedColor: primaryColor,
                inactiveColor: Colors.grey,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              onCompleted: (value) {
                setState(() {
                  _otpCode = value;
                });
              },
              onChanged: (value) {
                setState(() {
                  _otpCode = value;
                });
              },
              appContext: context,
            ),
            const SizedBox(height: 30.0),
            PrimaryButton(
              text: 'VERIFY',
              onPressed: () {
                // Handle OTP verification
                print('Entered OTP: $_otpCode');
                Navigator.pushNamedAndRemoveUntil(context,
                    RouteNames.verificationCompletedScreen, (route) => false);
                // Add your verification logic here
              },
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomText(
                    text: 'Didn’t receive any code?',
                    fontSize: 14.0,
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle resend code
                    },
                    child: const CustomText(
                      text: 'Resend Again',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Center(
              child: CustomText(
                text: 'Request new code in 00:30s',
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
