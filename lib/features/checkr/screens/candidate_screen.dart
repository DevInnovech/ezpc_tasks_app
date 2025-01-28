import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/checkr/model/candidate.dart';
import 'package:ezpc_tasks_app/features/checkr/model/checkr_service.dart';

class CandidateFormScreen extends StatefulWidget {
  const CandidateFormScreen({super.key});

  @override
  _CandidateFormScreenState createState() => _CandidateFormScreenState();
}

class _CandidateFormScreenState extends State<CandidateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController workLocationController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    workLocationController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Dividir y validar la ubicación de trabajo
        final locationParts = workLocationController.text.trim().split(',');
        if (locationParts.length != 2) {
          print("Invalid work_location format: Expected 'City, State'");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Work Location must be in 'City, ST' format."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

// Explicitly declare as List<Map<String, String>>
        final List<Map<String, String>> workLocation = [
          {
            "city": locationParts[0].trim(),
            "state": locationParts[1].trim(),
            "country": "US" // Ensure all values are Strings
          }
        ];

        print("Processed work_location: $workLocation");

        final candidate = Candidate(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          workLocations: workLocation, // Pass correctly formatted data
          zipcode: zipCodeController.text.trim(),
        );

        print("Candidate data to send: ${candidate.toJson()}");

        final result = await CheckrService.createCandidateAndSendInvitation({
          'first_name': candidate.firstName,
          'last_name': candidate.lastName,
          'email': candidate.email,
          'phone': candidate.phone,
          'work_locations': workLocation, // Ensure correct type
          'zipcode': candidate.zipcode,
        });

        if (result != null && result['success']) {
          print("Checkr Response: $result");

          // Guardar en Firestore
          await FirebaseFirestore.instance.collection('background_checks').add({
            'first_name': candidate.firstName,
            'last_name': candidate.lastName,
            'email': candidate.email,
            'phone': candidate.phone,
            'work_locations': candidate.workLocations,
            'zipcode': candidate.zipcode,
            'checkr_id': result['candidateId'],
            'invitation_url': result['invitationUrl'],
            'status': 'invitation_sent',
            'created_at': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Candidate created and invitation sent successfully"),
              backgroundColor: Colors.green,
            ),
          );

          // Limpiar el formulario
          _formKey.currentState!.reset();
          firstNameController.clear();
          lastNameController.clear();
          emailController.clear();
          phoneController.clear();
          workLocationController.clear();
          zipCodeController.clear();
        } else {
          print("Error in Checkr Response: ${result?['error']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${result?['error'] ?? 'Unknown error'}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Candidate Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextField(
                  controller: firstNameController,
                  label: "First Name",
                  validator: (value) => value == null || value.isEmpty
                      ? "First Name is required"
                      : null,
                ),
                buildTextField(
                  controller: lastNameController,
                  label: "Last Name",
                  validator: (value) => value == null || value.isEmpty
                      ? "Last Name is required"
                      : null,
                ),
                buildTextField(
                  controller: emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    final emailRegex =
                        RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: phoneController,
                  label: "Phone",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone is required";
                    }
                    if (value.length < 10) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: workLocationController,
                  label: "Work Location",
                  hintText: "City, ST (e.g., San Jose, CA)",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Work Location is required";
                    }
                    final locationParts = value.split(',');
                    if (locationParts.length != 2 ||
                        locationParts[0].trim().isEmpty ||
                        locationParts[1].trim().isEmpty) {
                      return "Work Location must be in 'City, ST' format";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: zipCodeController,
                  label: "Zipcode",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Zipcode is required";
                    }
                    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value)) {
                      return "Enter a valid Zipcode";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
