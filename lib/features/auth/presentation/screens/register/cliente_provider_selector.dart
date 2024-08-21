import 'dart:convert';

import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/provider_selector.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/accounts_selector.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AccountTypeSelectionScreen extends StatefulWidget {
  @override
  _AccountTypeSelectionScreenState createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen> {
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
            const SizedBox(height: 24.0),
            AccountTypeSelector(
              title: 'Provider',
              description: 'Provide tasks to customers',
              iconOrImage: Icon(
                Icons.engineering,
                color: primaryColor,
                size: iconSize,
              ),
              isSelected: selectedType == 'Provider',
              onTap: () {
                setState(() {
                  selectedType = 'Provider';
                });
              },
            ),
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
                        //   Navigator.pushNamed(context, RouteNames.registerClient);
                      } else if (selectedType == 'Provider') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderTypeSelectionScreen(),
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
