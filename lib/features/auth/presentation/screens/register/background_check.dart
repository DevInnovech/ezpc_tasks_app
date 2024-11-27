import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class BackgroundCheckPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  BackgroundCheckPage({super.key});

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
