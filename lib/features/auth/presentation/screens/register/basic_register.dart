import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class CreateAccountPage1 extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  CreateAccountPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(title: ""),
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
                  label: 'Email Address',
                  controller: emailController,
                  hintText: 'Enter your Email',
                  textValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: 'Name',
                        controller: nameController,
                        hintText: 'Enter your Name',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomForm2(
                        label: 'Last Name',
                        controller: lastNameController,
                        hintText: 'Enter your Last Name',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last Name cannot be empty';
                          }
                          return null;
                        },
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
                        controller: dobController,
                        isDateField: true, // Indica que este campo es una fecha
                        dateValidator: (value) {
                          if (value == null) {
                            return "Date of Birth is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomForm2(
                        label: 'Phone Number',
                        controller: phoneController,
                        hintText: 'Phone Number',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone Number cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                GooglePlaceAutoCompleteTextField(
                  //          useModernStyle: true,
                  textEditingController: addressController,
                  googleAPIKey:
                      "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Reemplaza con tu API Key

                  debounceTime: 800,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    debugPrint("Place Details: $prediction");
                  },
                  itemClick: (prediction) {
                    addressController.text = prediction.description!;
                    addressController.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description!.length));
                  },
                ),
                const SizedBox(height: 16.0),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Llamar a la función de registro con los datos ingresados
                      // Obtener los datos ingresados
                      String email = emailController.text;
                      String name = nameController.text;
                      String lastName = lastNameController.text;
                      //              DateTime dob = DateTime.parse(dobController.text); // Asegúrate de que este formato sea correcto
                      String phoneNumber = phoneController.text;
                      String address = addressController.text;

                      // Proceed to next page
                      Navigator.pushNamed(
                        context,
                        RouteNames.passwordAccountpage,
                        arguments: {
                          'email': email,
                          'name': name,
                          'lastName': lastName,
                          //     'dob': dob,
                          'phoneNumber': phoneNumber,
                          'address': address,
                        },
                      );
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
