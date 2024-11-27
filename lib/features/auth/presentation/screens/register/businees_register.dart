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

  BusinessAccountScreen({super.key});

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
              const EmployeeCodeField(employeeCode: "BSC76823"),
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
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Continue",
                onPressed: () {
                  // Recopilar datos de los controladores
                  final email = emailController.text;
                  final fin = finController.text;
                  final businessName = businessNameController.text;
                  final description = descriptionController.text;
                  final dob = dobController.text;
                  final phoneNumber = phoneController.text;

                  // Verifica que todos los campos requeridos no estén vacíos antes de navegar
                  if (email.isNotEmpty &&
                      fin.isNotEmpty &&
                      businessName.isNotEmpty &&
                      description.isNotEmpty &&
                      dob.isNotEmpty &&
                      phoneNumber.isNotEmpty) {
                    // Navegar a la siguiente página con los argumentos
                    Navigator.pushNamed(
                      context,
                      RouteNames.passwordAccountpage,
                      arguments: {
                        'email': email,
                        'fin': fin,
                        'businessName': businessName,
                        'description': description,
                        'dob': dob, // Nuevo argumento agregado
                        'phoneNumber': phoneNumber,
                      },
                    );
                  } else {
                    // Mostrar un mensaje de error o advertencia si hay campos vacíos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill in all fields")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
