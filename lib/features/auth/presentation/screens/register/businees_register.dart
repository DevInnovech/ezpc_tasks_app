import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/copy_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class BusinessAccountScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController finController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController employeeCodeController = TextEditingController();

  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Sign up to your\nBusiness Account',
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
              // generar el codigo que deseen
              EmployeeCodeField(employeeCode: "BSC76823"),
              Utils.verticalSpace(15),
              /*  CustomForm2(
                label: "Employee code assigned",
                hintText: "Enter employee code",
                controller: employeeCodeController,
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Employee code is required";
                  }
                  return null;
                },
              ),*/
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
      ),
    );
  }
}
