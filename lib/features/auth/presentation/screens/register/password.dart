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

  bool _isChecked = false; // Estado del checkbox
  bool _isAccepted = false; // Estado de aceptación de términos

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
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
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value!;
                          if (!_isChecked) {
                            _isAccepted = false;
                          }
                        });
                        if (_isChecked) {
                          _showTermsAndConditionsPopup(context);
                        }
                      },
                    ),
                    const Text('I agree to the Terms and Conditions'),
                  ],
                ),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _isAccepted
                      ? () async {
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
                                      : accountType ==
                                              AccountType.independentProvider
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
                              companyID:
                                  accountType == AccountType.corporateProvider
                                      ? companyID
                                      : null,
                              employeeCode: accountType ==
                                      AccountType.corporateProvider
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
                        }
                      : () {
                          // Mostrar SnackBar si no ha aceptado los términos
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You must accept the Terms and Conditions to continue.',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors
                                  .red, // Fondo rojo para enfatizar el error
                              duration: Duration(seconds: 3),
                            ),
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

  void _showTermsAndConditionsPopup(BuildContext context) {
    bool hasScrolledToEnd = false;

    showDialog(
      context: context,
      barrierDismissible: true, // Permitir cerrar tocando fuera
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white, // Fondo blanco
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Terms and Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 300,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      setState(() {
                        hasScrolledToEnd = true;
                      });
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Here are the terms and conditions...\n' *
                              20, // Texto largo de ejemplo
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: hasScrolledToEnd
                      ? () {
                          setState(() {
                            _isAccepted = true;
                            _isChecked = true;
                          });
                          Navigator.pop(context);
                        }
                      : null, // Deshabilitado hasta que lea completo
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Primary color
                    foregroundColor: Colors.white, // Texto blanco
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('I Agree'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Verificar si no se aceptaron los términos
      if (!_isAccepted) {
        setState(() {
          _isChecked = false; // Desmarcar el checkbox
        });
      }
    });
  }
}
