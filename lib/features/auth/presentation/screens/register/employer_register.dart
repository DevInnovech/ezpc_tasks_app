import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class SignUpWithBusinessCodeScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessCodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomForm2(
              label: "Email Address",
              hintText: "Enter your Email",
              controller: emailController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email cannot be empty";
                }
                final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegExp.hasMatch(value)) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Business Code",
              hintText: "Enter your Business Code",
              controller: businessCodeController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Business Code is required";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Name",
              hintText: "Enter your Name",
              controller: nameController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name cannot be empty";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Last Name",
              hintText: "Enter your Last Name",
              controller: lastNameController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Last Name cannot be empty";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Date of Birth",
              hintText: "Select your Birth Date",
              controller: birthDateController,
              isDateField: true, // Indica que este campo es una fecha
              dateValidator: (value) {
                if (value == null) {
                  return "Date of Birth is required";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Phone Number",
              hintText: "Phone Number",
              controller: phoneController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Phone number is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: "Continue",
              onPressed: () {
                // Acción al presionar continuar
                Navigator.pushNamed(
                  context,
                  RouteNames.passwordAccountpage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
