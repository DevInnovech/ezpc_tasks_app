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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final candidate = Candidate(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          workLocation: workLocationController.text.trim(),
          zipcode: zipCodeController.text.trim(),
        );

        final candidateId =
            await CheckrService.createCandidate(candidate.toJson());

        if (candidateId != null) {
          // Guardar en Firestore
          await FirebaseFirestore.instance.collection('background_checks').add({
            'first_name': candidate.firstName,
            'last_name': candidate.lastName,
            'email': candidate.email,
            'phone': candidate.phone,
            'work_location': candidate.workLocation,
            'zipcode': candidate.zipcode,
            'checkr_id': candidateId,
            'status': 'pending',
            'created_at': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Candidate created and saved successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error creating candidate")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e")),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Candidate Details")),
      body: Padding(
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
                label: "Work Location (City, State)",
                validator: (value) => value == null || value.isEmpty
                    ? "Work Location is required"
                    : null,
              ),
              buildTextField(
                controller: zipCodeController,
                label: "Zipcode",
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
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
