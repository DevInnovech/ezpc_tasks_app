import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_socialbutton.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class SignUpWithBusinessCodeScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessCodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  SignUpWithBusinessCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              Row(
                children: [
                  Expanded(
                    child: CustomForm2(
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
                  ),
                  Utils.horizontalSpace(10),
                  Expanded(
                    child: CustomForm2(
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
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomForm2(
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
                  ),
                  Utils.horizontalSpace(10),
                  Expanded(
                    child: CustomForm2(
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
                  ),
                ],
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
              Utils.verticalSpace(12.0),
              _sugnup_extras(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sugnup_extras(BuildContext context) {
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
            onTap: () {
              // Handle Google login
            },
          ),
          Utils.horizontalSpace(6.0),
          SocialButton(
            imagePath: KImages.facebookIcon,
            color: Colors.black,
            onTap: () {
              // Handle Facebook login
            },
          ),
          Utils.horizontalSpace(6.0),
          SocialButton(
            imagePath: KImages.applelogo, // Replace with your asset path
            color: Colors.black,

            onTap: () {
              // Handle Apple login
            },
          ),
        ],
      ),
    ],
  );
}
