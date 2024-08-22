import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class BusinessAccountScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController finController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController employeeCodeController = TextEditingController();

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
                return null;
              },
            ),
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
              label: "Business FIN",
              hintText: "Enter your Business FIN",
              controller: finController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Business FIN is required";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Business Name",
              hintText: "Enter your Business Name",
              controller: businessNameController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Business Name cannot be empty";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Business Description",
              hintText: "Enter your Business Description",
              controller: descriptionController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Business Description cannot be empty";
                }
                return null;
              },
            ),
            CustomForm2(
              label: "Employee code assigned",
              hintText: "Enter employee code",
              controller: employeeCodeController,
              textValidator: (value) {
                if (value == null || value.isEmpty) {
                  return "Employee code is required";
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
