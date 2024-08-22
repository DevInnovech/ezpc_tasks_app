import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordAccountpage extends ConsumerStatefulWidget {
  @override
  ConsumerState<PasswordAccountpage> createState() =>
      _PasswordAccountpageState();
}

class _PasswordAccountpageState extends ConsumerState<PasswordAccountpage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomForm2(
                label: 'Username',
                controller: usernameController,
                hintText: 'Enter your Username',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
                hintText: 'Enter your Password',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: 'Confirm Password',
                controller: confirmPasswordController,
                obscureText: true,
                hintText: 'Confirm your Password',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password confirmation cannot be empty';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (val) {}),
                  Text('I agree to the Terms and Conditions')
                ],
              ),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Proceed to next page

                    final accountType = ref.watch(accountTypeProvider);

                    if (accountType == AccountType.client) {
                      // Lógica para cliente
                      Navigator.pushNamed(
                        context,
                        RouteNames.addCardPaymentMethodScreen,
                      );
                    } else if (accountType == AccountType.corporateProvider) {
                      // Lógica para proveedor corporativo
                      Navigator.pushNamed(
                        context,
                        RouteNames.addBankAccountInformationScreen,
                      );
                    } else if (accountType == AccountType.independentProvider) {
                      // Lógica para proveedor independiente
                      Navigator.pushNamed(
                        context,
                        RouteNames.addBankAccountInformationScreen,
                      );
                    } else if (accountType == AccountType.employeeProvider) {
                      // Lógica para proveedor empleado
                      Navigator.pushNamed(
                        context,
                        RouteNames.addBankAccountInformationScreen,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
