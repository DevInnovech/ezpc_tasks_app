import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ClientRegistrationExistingScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

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
            const SizedBox(height: 20),
            const Text(
              "You are registered as Provider, please check your email to confirm this request.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: "Back to Sign Up",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
