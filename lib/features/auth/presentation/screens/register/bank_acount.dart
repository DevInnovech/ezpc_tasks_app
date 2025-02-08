import 'package:ezpc_tasks_app/features/Stripe_Connect/redirectToStripeConnect.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBankAccountPage extends ConsumerStatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  ConsumerState<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends ConsumerState<AddBankAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Connect Bank Account"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 100,
              color: primaryColor,
            ),
            Utils.verticalSpace(20),
            const CustomText(
              text:
                  'Payments for service providers are securely managed by Stripe, our trusted 3rd party payment provider.',
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
              color: Colors.black87,
            ),
            Utils.verticalSpace(40),
            PrimaryButton(
              text: 'Connect Bank Account with Stripe',
              onPressed: () async {
                // Lógica para conectarse a Stripe
                await redirectToStripeConnect();
              },
            ),
            Utils.verticalSpace(10),
            PrimaryButton(
              text: 'Skip - Do it later',
              bgColor: Colors.orange,
              onPressed: () {
                // Redirigir a WelcomeBackgroundCheckScreen
                Navigator.pushNamed(
                  context,
                  RouteNames.createCandidateScreen,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
