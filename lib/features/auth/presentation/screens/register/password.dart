import 'package:ezpc_tasks_app/features/auth/data/auth_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordAccountpage extends ConsumerStatefulWidget {
  const PasswordAccountpage({super.key});

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
    final accountType = ref.watch(accountTypeProvider);

    String email;
    String name;
    String companyID;
    String lastName;
    //  DateTime dob = args['dob'];
    String phoneNumber;
    String address;
    String description;
    String employercode;
    var dob;

    // Obtener los argumentos de la página anterior
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    print(args);
    switch (accountType) {
      case AccountType.employeeProvider:
        email = args['email'];
        name = args['name'];
        companyID = '';
        lastName = args['lastName'];
        dob = args['dob'];
        description = '';
        phoneNumber = args['phoneNumber'];
        employercode = args['employercode'];
        address = args['address'];

        break;
      case AccountType.corporateProvider:
        email = args['email'];
        name = args['businessName'];
        companyID = args['companyID'];
        employercode = args['employercode'];
        lastName = '';
        dob = args['dob'];
        description = args['description'];
        phoneNumber = args['phoneNumber'];
        address = args['address'];

        break;
      default:
        email = args['email'];
        name = args['name'];
        companyID = "";
        description = "";
        employercode = "";
        dob = args['dob'];
        lastName = args['lastName'];
        phoneNumber = args['phoneNumber'];
        address = args['address'];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                  text: 'Sign up to your\nAccount',
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                Utils.verticalSpace(10),
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
                    const Text('I agree to the Terms and Conditions')
                  ],
                ),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Llamar a la función de registro
                      String username = usernameController.text;
                      String password = passwordController.text;

                      // Crear instancia de AuthService
                      var authService =
                          AuthService(); // Instancia de AuthService

                      // Llamar a la función de registro
                      var user = await authService.SignUpMethod(
                        email: email,
                        name: name,
                        lastName: lastName,
                        //       dob: dob,
                        phoneNumber: phoneNumber,
                        username: username,
                        password: password,
                        address: address,
                        role: accountType == AccountType.client
                            ? 'Client'
                            : accountType == AccountType.corporateProvider
                                ? 'Corporate Provider'
                                : accountType == AccountType.independentProvider
                                    ? 'Independent Provider'
                                    : accountType ==
                                            AccountType.employeeProvider
                                        ? 'Employee Provider'
                                        : '',
                        description: description,
                        communicationPreference: '',
                        experienceYears: 0,
                        languages: '',
                        preferredPaymentMethod: '',
                        profileImageUrl: '', accountType: '',
                        companyID: accountType == AccountType.corporateProvider
                            ? companyID
                            : null,
                        employeeCode:
                            accountType == AccountType.corporateProvider
                                ? employercode
                                : accountType == AccountType.employeeProvider
                                    ? employercode
                                    : null,
                      );

                      if (user != null) {
                        // Navegar a la siguiente pantalla dependiendo del tipo de cuenta
                        if (accountType == AccountType.client) {
                          Navigator.pushNamed(
                            context,
                            RouteNames.addCardPaymentMethodScreen,
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            RouteNames.addBankAccountInformationScreen,
                          );
                        }
                      } else {
                        // Manejo de error si el registro falla
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to create account')),
                        );
                      }
                    }
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
