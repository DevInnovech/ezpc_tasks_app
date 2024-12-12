import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class BackgroundCheckPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Future<void> createCandidate(
      BuildContext context, Map<String, dynamic> candidateData) async {
    const String apiKey = "YOUR_CHECKR_API_KEY";
    const String candidateEndpoint = "https://api.checkr.com/v1/candidates";

    try {
      final response = await http.post(
        Uri.parse(candidateEndpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode(candidateData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Candidate created: $data");

        // Crear la invitación
        final candidateId = data['id'];
        await createInvitation(context, candidateId);
      } else {
        print("Error creating candidate: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error creating candidate. Please try again.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Unexpected error occurred. Please try again.")),
      );
    }
  }

  Future<void> createInvitation(
      BuildContext context, String candidateId) async {
    const String apiKey = "YOUR_CHECKR_API_KEY";
    const String invitationEndpoint = "https://api.checkr.com/v1/invitations";

    try {
      final response = await http.post(
        Uri.parse(invitationEndpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "candidate_id": candidateId,
          "package":
              "your_package_id", // Cambia esto al ID de tu paquete configurado en Checkr
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Invitation created: $data");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Background check initiated successfully.")),
        );
      } else {
        print("Error creating invitation: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error creating invitation. Please try again.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Unexpected error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    /*  final TextEditingController ssnController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(title: ""),*/
    final TextEditingController emailController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Background Check")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          /* child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Background Check',
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                Utils.verticalSpace(10),
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
                    const SizedBox(width: 16),
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
                  suffixIcon: const Icon(Icons.credit_card),
                  hintText: ' Social Security Number',
                  textValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'SSN cannot be empty';
                    }
                    return null;
                  },
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
                    Utils.horizontalSpace(10),
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
                    const SizedBox(width: 16),
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
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.accountTypeSelectionScreen),
                    child: const CustomText(
                      text: 'Upload suported document *',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                      height: 1.6,
                    ),
                  ),
                ),
                Utils.verticalSpace(10),
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
            ),*/
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(labelText: "Country"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(labelText: "State"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final candidateData = {
                      "first_name": nameController.text,
                      "last_name": lastNameController.text,
                      "email": emailController.text,
                      "work_location": {
                        "country": countryController.text,
                        "state": stateController.text,
                        "city": cityController.text,
                      },
                    };
                    createCandidate(context, candidateData);
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
