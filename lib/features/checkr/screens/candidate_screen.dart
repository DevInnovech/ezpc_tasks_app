import 'package:ezpc_tasks_app/features/checkr/screens/candidate_processing_screen.dart';
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
        // Validate and parse work location
        final locationParts = workLocationController.text.trim().split(',');
        if (locationParts.length != 2) {
          print("Invalid work_location format");
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

        final List<Map<String, String>> workLocation = [
          {
            "city": locationParts[0].trim(),
            "state": locationParts[1].trim(),
            "country": "US"
          }
        ];

        print("Processed work_location: $workLocation");

        final candidate = Candidate(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          workLocations: workLocation,
          zipcode: zipCodeController.text.trim(),
        );

        print("Candidate data to send: ${candidate.toJson()}");

        final result = await CheckrService.createCandidateAndSendInvitation({
          'first_name': candidate.firstName,
          'last_name': candidate.lastName,
          'email': candidate.email,
          'phone': candidate.phone,
          'work_locations': workLocation,
          'zipcode': candidate.zipcode,
        });

        if (result != null && result['success']) {
          final candidateId = result['candidateId'];
          final invitationUrl = result['invitationUrl'];

          print("Checkr Response: $result");

          // Save in Firestore
          await FirebaseFirestore.instance
              .collection('background_checks')
              .doc(candidateId)
              .set({
            'first_name': candidate.firstName,
            'last_name': candidate.lastName,
            'email': candidate.email,
            'phone': candidate.phone,
            'work_locations': candidate.workLocations,
            'zipcode': candidate.zipcode,
            'checkr_id': candidateId,
            'invitation_url': invitationUrl,
            'status': 'processing', // Initial status
            'created_at': Timestamp.now(),
          });

          // Navigate to CandidateProcessingScreen
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateProcessingScreen(
                    candidateId: candidateId, email: candidate.email),
              ),
            );
          }
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
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.deepPurple)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: Colors.deepPurple),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Candidate Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField(
                            controller: firstNameController,
                            label: "First Name",
                            prefixIcon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty
                                ? "First Name is required"
                                : null,
                          ),
                          buildTextField(
                            controller: lastNameController,
                            label: "Last Name",
                            prefixIcon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty
                                ? "Last Name is required"
                                : null,
                          ),
                          buildTextField(
                            controller: emailController,
                            label: "Email",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              final emailRegex = RegExp(
                                  r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                              if (!emailRegex.hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                          buildTextField(
                            controller: phoneController,
                            label: "Phone",
                            prefixIcon: Icons.phone_outlined,
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
                            prefixIcon: Icons.location_on_outlined,
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
                            prefixIcon: Icons.map_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Zipcode is required";
                              }
                              if (!RegExp(r'^\d{5}(-\d{4})?$')
                                  .hasMatch(value)) {
                                return "Enter a valid Zipcode";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Text(
                                      "Submit Application",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
