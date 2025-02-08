import 'package:ezpc_tasks_app/features/Stripe_Connect/redirectToStripeConnect.dart';
import 'package:ezpc_tasks_app/features/auth/data/auth_service.dart';
import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool _isChecked = false;
  bool _isAccepted = false;
  bool _isLoading = false;

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
    String phoneNumber;
    String address;
    String description;
    String employercode;
    String? specialRegister;
    User? userSpecial;
    var dob;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;

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
        specialRegister = args['special_register'];
        userSpecial = args['user_special'];
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Continue',
                        onPressed: _isAccepted
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  String username = usernameController.text;
                                  String password = passwordController.text;

                                  var authService = AuthService();

                                  var documentId =
                                      await authService.SignUpMethod(
                                    email: email,
                                    name: name,
                                    lastName: lastName,
                                    phoneNumber: phoneNumber,
                                    username: username,
                                    password: password,
                                    address: address,
                                    role: accountType == AccountType.client
                                        ? 'Client'
                                        : accountType ==
                                                AccountType.corporateProvider
                                            ? 'Corporate Provider'
                                            : accountType ==
                                                    AccountType
                                                        .independentProvider
                                                ? 'Independent Provider'
                                                : accountType ==
                                                        AccountType
                                                            .employeeProvider
                                                    ? 'Employee Provider'
                                                    : '',
                                    description: description,
                                    communicationPreference: '',
                                    experienceYears: 0,
                                    languages: '',
                                    preferredPaymentMethod: '',
                                    profileImageUrl: '',
                                    accountType: '',
                                    companyID: accountType ==
                                            AccountType.corporateProvider
                                        ? companyID
                                        : null,
                                    employeeCode: accountType ==
                                            AccountType.corporateProvider
                                        ? employercode
                                        : accountType ==
                                                AccountType.employeeProvider
                                            ? employercode
                                            : null,
                                    special_register: specialRegister,
                                    user_special: userSpecial,
                                  );

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (documentId != null) {
                                    showSuccessMessage(context);
                                    await Future.delayed(
                                        const Duration(seconds: 2));

                                    // Aquí pasamos el ID del documento a la siguiente pantalla
                                    if (accountType == AccountType.client) {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.addCardPaymentMethodScreen,
                                        arguments: {'documentId': documentId},
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames
                                            .addBankAccountInformationScreen,
                                        arguments: {'documentId': documentId},
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Failed to create account'),
                                      ),
                                    );
                                  }
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You must accept the Terms and Conditions to continue.',
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.red,
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
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
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
                          'Here are the terms and conditions...\n' * 20,
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
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
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
      if (!_isAccepted) {
        setState(() {
          _isChecked = false;
        });
      }
    });
  }

  void showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text(
            'Your account has been registered successfully. We have sent a confirmation email to your address.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
