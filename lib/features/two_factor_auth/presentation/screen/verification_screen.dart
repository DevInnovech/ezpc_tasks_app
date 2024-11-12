import 'dart:async';
import 'package:ezpc_tasks_app/features/two_factor_auth/data/two_factor_provider.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String authMethod;

  const VerificationScreen({Key? key, required this.authMethod})
      : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String _otpCode = '';
  bool isResendButtonEnabled = false;
  int resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startResendCountdown();
  }

  void startResendCountdown() {
    setState(() {
      isResendButtonEnabled = false;
      resendTimer = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          isResendButtonEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Two-factor authentication is on',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        content: const CustomText(
          text: 'From now, we will ask you for a code to sign in.',
          fontSize: 16.0,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Actualiza el método de autenticación solo si la verificación es exitosa
              ref.read(authMethodProvider.notifier).state = widget.authMethod;
              Navigator.pop(context); // Cerrar el diálogo
              Navigator.pop(context); // Regresar a la pantalla principal
            },
            child: const Text('Got it', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Invalid Code',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        content: const CustomText(
          text: 'The code you entered is incorrect. Please try again.',
          fontSize: 16.0,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Retry', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
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
                  'A 6-digit code was sent to your phone number or email. Please enter the code to continue.',
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
              onPressed: () async {
                final isValid =
                    await ref.read(verificationProvider(_otpCode).future);
                if (isValid) {
                  ref.read(verificationStatusProvider.notifier).state = true;
                  showSuccessDialog(context);
                } else {
                  showErrorDialog(context);
                }
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
                    onPressed: isResendButtonEnabled
                        ? () {
                            startResendCountdown();
                          }
                        : null,
                    child: CustomText(
                      text: 'Resend Again',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: isResendButtonEnabled ? primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: CustomText(
                text:
                    'Request new code in 00:${resendTimer.toString().padLeft(2, '0')}s',
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
