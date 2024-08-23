import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateAccountPage1 extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: ""),
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
                    SizedBox(width: 16),
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
                    SizedBox(width: 16),
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
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Proceed to next page
                      Navigator.pushNamed(
                        context,
                        RouteNames.passwordAccountpage,
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
