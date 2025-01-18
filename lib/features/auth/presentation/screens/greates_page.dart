import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';

class VerificationCompletedScreen extends ConsumerWidget {
  final String title; // Título dinámico
  final String subtitle; // Subtítulo dinámico
  final VoidCallback onContinue; // Acción al presionar "Continue"

  const VerificationCompletedScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomImage(
              path: KImages.verificationCompletedIcon, // Icono de verificación
              height: 100.0,
              width: 100.0,
              url: null,
            ),
            const SizedBox(height: 20.0),
            CustomText(
              text: title,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            const SizedBox(height: 10.0),
            CustomText(
              text: subtitle,
              fontSize: 16.0,
              color: primaryColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            PrimaryButton(
              text: 'Continue',
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
