import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBankAccountPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends ConsumerState<AddBankAccountPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController accountHolderController =
        TextEditingController();
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController bankCodeController = TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Add Card Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomForm2(
                label: 'Account Holder Name',
                controller: accountHolderController,
                hintText: 'Enter your account Holder name',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account Holder Name cannot be empty';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: 'Bank Name',
                controller: bankNameController,
                hintText: 'Enter your Bank Name',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bank Name cannot be empty';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: 'Bank Code',
                controller: bankCodeController,
                hintText: 'Enter your Bank Code',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bank Code cannot be empty';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: 'Account Number',
                controller: accountNumberController,
                hintText: 'Enter your Account Number',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account Number cannot be empty';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Save',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Proceed to save data

                          final accountType = ref.watch(accountTypeProvider);

                          if (accountType == AccountType.client) {
                            // Lógica para cliente
                            Navigator.pushNamed(
                              context,
                              RouteNames.verificationSelectionScreen,
                            );
                          } else if (accountType ==
                              AccountType.corporateProvider) {
                            // Lógica para proveedor corporativo
                            Navigator.pushNamed(
                              context,
                              RouteNames.backgroundCheckScreen,
                            );
                          } else if (accountType ==
                              AccountType.independentProvider) {
                            // Lógica para proveedor independiente
                            Navigator.pushNamed(
                              context,
                              RouteNames.backgroundCheckScreen,
                            );
                          } else if (accountType ==
                              AccountType.employeeProvider) {
                            // Lógica para proveedor empleado
                            Navigator.pushNamed(
                              context,
                              RouteNames.verificationSelectionScreen,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Skip - Do it later',
                      onPressed: () {
                        // Skip action
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
