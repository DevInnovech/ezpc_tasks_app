import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/accounts_selector.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountTypeSelectionScreen extends ConsumerStatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  _AccountTypeSelectionScreenState createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends ConsumerState<AccountTypeSelectionScreen> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    // Definimos un tamaño base relativo al ancho de la pantalla
    final iconSize = screenWidth * 0.1; // 10% del ancho de la pantalla

    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text:
                  'Welcome to EZPC Tasks,\nPlease select your role to continue.',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            Utils.verticalSpace(10.0),
            AccountTypeSelector(
              title: 'Business Provider',
              description:
                  'A company that offers tasks to clients through a network of agents or professionals.',
              iconOrImage: CustomImage(
                path: KImages.corporatesvg,
                height: iconSize,
                width: iconSize,
                url: null,
              ),
              isSelected: selectedType == 'Corporate',
              onTap: () {
                setState(() {
                  selectedType = 'Corporate';
                });
              },
            ),
            const SizedBox(height: 24.0),
            AccountTypeSelector(
              title: 'Independent Provider',
              description: 'Provide tasks as an independent contractor',
              iconOrImage: Icon(
                Icons.engineering,
                color: primaryColor,
                size: iconSize,
              ),
              isSelected: selectedType == 'Independent',
              onTap: () {
                setState(() {
                  selectedType = 'Independent';
                });
              },
            ),
            Utils.verticalSpace(10.0),
            Utils.verticalSpace(10.0),
            AccountTypeSelector(
              title: 'Client',
              description: 'Looking for tasks',
              iconOrImage: Icon(
                Icons.person,
                color: primaryColor,
                size: iconSize,
              ),
              isSelected: selectedType == 'Client',
              onTap: () {
                setState(() {
                  selectedType = 'Client';
                });
              },
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: selectedType == null
                  ? null
                  : () {
                      if (selectedType == 'Client') {
                        ref
                            .read(accountTypeProvider.notifier)
                            .selectAccountType(AccountType.client);
                        Navigator.pushNamed(
                            context, RouteNames.createAccountScreen);
                      } else if (selectedType == 'Independent') {
                        ref
                            .read(accountTypeProvider.notifier)
                            .selectAccountType(AccountType.independentProvider);

                        Navigator.pushNamed(
                          context,
                          RouteNames.createAccountScreen,
                        );
                      } else if (selectedType == 'Corporate') {
                        Navigator.pushNamed(
                          context,
                          RouteNames.providerSelectionEmployer,
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
