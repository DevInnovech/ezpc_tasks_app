import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/accounts_selector.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class IndependentProviderSelectionScreen extends StatefulWidget {
  @override
  _IndependentProviderSelectionScreenState createState() =>
      _IndependentProviderSelectionScreenState();
}

class _IndependentProviderSelectionScreenState
    extends State<IndependentProviderSelectionScreen> {
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
            const SizedBox(height: 24.0),
            AccountTypeSelector(
              title: 'Independent Provider',
              description: 'Provide tasks as an independent contractor',
              iconOrImage: Icon(
                Icons.engineering,
                color: primaryColor,
                size: iconSize,
              ),
              isSelected: selectedIndependentType == 'Independent',
              onTap: () {
                setState(() {
                  selectedIndependentType = 'Independent';
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
                      if (selectedIndependentType == 'Independent') {
                        /*   Navigator.pushNamed(
                          context,
                          RouteNames.registerIndependentProvider,
                        );*/
                      } else if (selectedIndependentType == 'Employee') {
                        /* Navigator.pushNamed(
                          context,
                          RouteNames.registerEmployee,
                        );*/
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
