import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
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
    final TextEditingController bankbranchCodeController =
        TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text:
                      'Please add your bank account\ninformation to receive payments',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                Utils.verticalSpace(10),
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
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomForm2(
                        label: 'Bank Name',
                        controller: bankNameController,
                        suffixIcon: Icon(Icons.corporate_fare_rounded,
                            color: Colors.grey),
                        hintText: 'Enter your Bank Name',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bank Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      Utils.verticalSpace(16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomForm2(
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
                          ),
                          Utils.horizontalSpace(10),
                          Expanded(
                            child: CustomForm2(
                              label: "Branch code",
                              hintText: "Branch code",
                              controller: bankbranchCodeController,
                              textValidator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Branch code is required";
                                }
                                if (value.length < 3 || value.length > 4) {
                                  return "Branch code must be 3 or 4 digits";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Utils.verticalSpace(10),
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
                PrimaryButton(
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
                      } else if (accountType == AccountType.corporateProvider) {
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
                      } else if (accountType == AccountType.employeeProvider) {
                        // Lógica para proveedor empleado
                        Navigator.pushNamed(
                          context,
                          RouteNames.verificationSelectionScreen,
                        );
                      }
                    }
                  },
                ),
                Utils.verticalSpace(10),
                PrimaryButton(
                  text: 'Skip - Do it later',
                  bgColor: Colors.orange,
                  onPressed: () {
                    // Skip action
                    Navigator.pushNamed(
                      context,
                      RouteNames.backgroundCheckScreen,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
