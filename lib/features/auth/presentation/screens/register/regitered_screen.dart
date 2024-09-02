import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ClientRegistrationExistingScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ClientRegistrationExistingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Don’t have an Account?\nCreate your account',
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                height: 1,
                color: primaryColor,
              ),
              Utils.verticalSpace(20),
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
              const CustomText(
                text:
                    'You are registered as Provider,\nplease check your email to confirm this request.',
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: primaryColor,
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
      ),
    );
  }
}
