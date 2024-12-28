import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_socialbutton.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:flutter/material.dart';

class SignUpWithBusinessCodeScreen extends StatefulWidget {
  const SignUpWithBusinessCodeScreen({super.key});

  @override
  _SignUpWithBusinessCodeScreenState createState() =>
      _SignUpWithBusinessCodeScreenState();
}

class _SignUpWithBusinessCodeScreenState
    extends State<SignUpWithBusinessCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessCodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  DateTime? dob; // Ahora es un DateTime? para manejar la fecha seleccionada

  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of Birth is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number cannot be empty';
    }
    if (value.length < 10) {
      return 'Phone Number must be at least 10 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  label: "Email Address",
                  hintText: "Enter your Email",
                  controller: emailController,
                  textValidator: validateEmail,
                ),
                CustomForm2(
                  label: "Business Code",
                  hintText: "Enter your Business Code",
                  controller: businessCodeController,
                  textValidator: (value) =>
                      validateRequiredField(value, 'Business Code'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: "Name",
                        hintText: "Enter your Name",
                        controller: nameController,
                        textValidator: (value) =>
                            validateRequiredField(value, 'Name'),
                      ),
                    ),
                    Utils.horizontalSpace(10),
                    Expanded(
                      child: CustomForm2(
                        label: "Last Name",
                        hintText: "Enter your Last Name",
                        controller: lastNameController,
                        textValidator: (value) =>
                            validateRequiredField(value, 'Last Name'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: "Date of Birth",
                        hintText: "Select your Birth Date",
                        controller:
                            TextEditingController(), // No se necesita controlador aquí
                        isDateField: true,
                        dateValidator:
                            validateDateOfBirth, // Usa el validador de fecha
                        onChangeddate: (DateTime? newDate) {
                          setState(() {
                            dob = newDate; // Actualiza la fecha seleccionada
                          });
                        },
                      ),
                    ),
                    Utils.horizontalSpace(10),
                    Expanded(
                      child: CustomForm2(
                        label: "Phone Number",
                        hintText: "Phone Number",
                        controller: phoneController,
                        textValidator: validatePhoneNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: addressController,
                  googleAPIKey:
                      "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Replace with your API Key
                  debounceTime: 800,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    debugPrint("Place Details: \$prediction");
                  },
                  itemClick: (prediction) {
                    addressController.text = prediction.description!;
                    addressController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description!.length),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final Map<String, dynamic> data = {
                        'email': emailController.text,
                        'employercode': businessCodeController.text,
                        'name': nameController.text,
                        'lastName': lastNameController.text,
                        'dob': dob,
                        'phoneNumber': phoneController.text,
                        'address': addressController.text,
                      };

                      Navigator.pushNamed(
                        context,
                        RouteNames.passwordAccountpage,
                        arguments: data,
                      );
                    }
                  },
                ),
                Utils.verticalSpace(12),
                _signupExtras(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupExtras(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CustomText(
          text: "or sign up with",
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: primaryColor,
          height: 1.2,
          textAlign: TextAlign.center,
        ),
        Utils.verticalSpace(12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              imagePath: KImages.googleIcon,
              color: Colors.black,
              onTap: () {},
            ),
            Utils.horizontalSpace(6.0),
            SocialButton(
              imagePath: KImages.facebookIcon,
              color: Colors.black,
              onTap: () {},
            ),
            Utils.horizontalSpace(6.0),
            SocialButton(
              imagePath: KImages.applelogo,
              color: Colors.black,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
