import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';

class VerificationCompletedScreen extends ConsumerWidget {
  const VerificationCompletedScreen({super.key});

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
            ),
            const SizedBox(height: 20.0),
            const CustomText(
              text: 'Congratulations! 🎉',
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            const SizedBox(height: 10.0),
            const CustomText(
              text: 'Your account has been verified!',
              fontSize: 16.0,
              color: primaryColor,
            ),
            const SizedBox(height: 40.0),
            PrimaryButton(
              text: 'Continue',
              onPressed: () {
                final accountType = ref.watch(accountTypeProvider);

                // Dependiendo del tipo de cuenta, redirigir a la pantalla principal correspondiente
                if (accountType == AccountType.client) {
                  // Lógica para cliente
                  /*   Navigator.pushNamed(
                    context,
                    RouteNames.addCardPaymentMethodScreen,
                  );*/
                } else if (accountType == AccountType.corporateProvider) {
                  // Lógica para proveedor corporativo
                } else if (accountType == AccountType.independentProvider) {
                  // Lógica para proveedor independiente
                } else if (accountType == AccountType.employeeProvider) {
                  // Lógica para proveedor empleado
                } else {
                  // Manejar el caso en que no se haya seleccionado un tipo de cuenta
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account type not selected.'),
                    ),
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
