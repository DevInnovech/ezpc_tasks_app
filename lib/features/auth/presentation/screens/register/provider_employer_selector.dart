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

class IndependentProviderSelectionScreen extends ConsumerStatefulWidget {
  @override
  _IndependentProviderSelectionScreenState createState() =>
      _IndependentProviderSelectionScreenState();
}

class _IndependentProviderSelectionScreenState
    extends ConsumerState<IndependentProviderSelectionScreen> {
  String? selectedIndependentType;

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    // Definimos un tamaño base relativo al ancho de la pantalla
    final iconSize = screenWidth * 0.1; // 10% del ancho de la pantalla

    return Scaffold(
      appBar: CustomAppBar(title: ''),
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
              title: 'Corporate Provider',
              description:
                  'A company that offers tasks to clients through a network of agents or professionals.',
              iconOrImage: CustomImage(
                path: KImages.corporatesvg,
                height: iconSize,
                width: iconSize,
              ),
              isSelected: selectedIndependentType == 'Corporate',
              onTap: () {
                setState(() {
                  selectedIndependentType = 'Corporate';
                });
              },
            ),
            Utils.verticalSpace(10.0),
            AccountTypeSelector(
              title: 'Employee',
              description: 'Provide task on behalf of a company',
              iconOrImage: Icon(
                Icons.people_rounded,
                color: primaryColor,
                size: iconSize,
              ),
              isSelected: selectedIndependentType == 'Employee',
              onTap: () {
                setState(() {
                  selectedIndependentType = 'Employee';
                });
              },
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: selectedIndependentType == null
                  ? null
                  : () {
                      if (selectedIndependentType == 'Corporate') {
                        ref
                            .read(accountTypeProvider.notifier)
                            .selectAccountType(AccountType.corporateProvider);

                        Navigator.pushNamed(
                          context,
                          RouteNames.signUpBusinessAccountScreen,
                        );
                      } else if (selectedIndependentType == 'Employee') {
                        ref
                            .read(accountTypeProvider.notifier)
                            .selectAccountType(AccountType.employeeProvider);

                        Navigator.pushNamed(
                          context,
                          RouteNames.signUpWithBusinessCodeScreen,
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
