import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class BackgroundCheckPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController ssnController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController zipCodeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Background Check')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              CustomForm2(
                label: 'SSN Information',
                controller: ssnController,
                hintText: 'Enter your Social Security Number',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'SSN cannot be empty';
                  }
                  return null;
                },
              ),
              CustomForm2(
                label: "Date of Birth",
                hintText: "Select your Birth Date", controller: dobController,
                isDateField: true, // Indica que este campo es una fecha
                dateValidator: (value) {
                  if (value == null) {
                    return "Date of Birth is required";
                  }
                  return null;
                },
              ),
              CustomForm2(
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
              CustomForm2(
                label: 'Address',
                controller: addressController,
                hintText: 'Enter your Address',
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address cannot be empty';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomForm2(
                      label: 'State',
                      controller: stateController,
                      hintText: 'Enter your State',
                      textValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'State cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomForm2(
                      label: 'Zip Code',
                      controller: zipCodeController,
                      hintText: 'Enter your Zip Code',
                      textValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Zip Code cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                text: 'Submit',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit the form
                    Navigator.pushNamed(
                      context,
                      RouteNames.verificationSelectionScreen,
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
