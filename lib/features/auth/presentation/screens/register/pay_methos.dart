import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class PaymentInformationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

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
                text: 'Do you want to add your\nPayment Method?',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              Utils.verticalSpace(10),
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
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomForm2(
                      label: "Card number",
                      hintText: "Enter your card number",
                      controller: cardNumberController,
                      suffixIcon: Icon(Icons.credit_card, color: Colors.grey),
                      textValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Card number is required";
                        }
                        if (value.length < 16) {
                          return "Card number must be 16 digits";
                        }
                        return null;
                      },
                    ),
                    Utils.verticalSpace(16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomForm2(
                            label: "Expiration",
                            hintText: "MM/YY",
                            controller: expirationController,
                            textValidator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Expiration date is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        Utils.horizontalSpace(10),
                        Expanded(
                          child: CustomForm2(
                            label: "CVV",
                            hintText: "CVV",
                            controller: cvvController,
                            textValidator: (value) {
                              if (value == null || value.isEmpty) {
                                return "CVV is required";
                              }
                              if (value.length < 3 || value.length > 4) {
                                return "CVV must be 3 or 4 digits";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CustomForm2(
                label: "Address",
                hintText: "Enter your address",
                controller: addressController,
                textValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Address is required";
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomForm2(
                      label: "State",
                      hintText: "Enter your state",
                      controller: stateController,
                      textValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return "State is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  Utils.horizontalSpace(10),
                  Expanded(
                    child: CustomForm2(
                      label: "Zip Code",
                      hintText: "Enter your zip code",
                      controller: zipCodeController,
                      textValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Zip Code is required";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Save",
                onPressed: () {
                  // Acción al presionar guardar
                  Navigator.pushNamed(
                    context,
                    RouteNames.verificationSelectionScreen,
                  );
                },
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: "Skip - Do it later",
                onPressed: () {
                  // Acción al presionar omitir
                },
                bgColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
