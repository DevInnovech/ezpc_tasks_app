import 'package:ezpc_tasks_app/features/checkr/data/moc_data/moc_check_service.dart';
import 'package:ezpc_tasks_app/features/checkr/model/candidate.dart';
import 'package:ezpc_tasks_app/features/checkr/screens/candidate_result.dart';
import 'package:flutter/material.dart';

class CreateCandidateScreen extends StatefulWidget {
  const CreateCandidateScreen({super.key});

  @override
  _CreateCandidateScreenState createState() => _CreateCandidateScreenState();
}

class _CreateCandidateScreenState extends State<CreateCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _candidate = Candidate(
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    workLocation: '',
    customId: '',
  );

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final result =
            await MockCheckrService.createCandidate(_candidate.toJson());
        if (result != null) {
          _showSnackBar('Candidate created with ID: ${result['custom_id']}');
          _simulateStatusUpdate(result['custom_id']);
        } else {
          _showSnackBar('Candidate not found in mock data');
        }
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _simulateStatusUpdate(String candidateId) {
    MockCheckrService.simulateStatusUpdate(candidateId, (newStatus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CandidateResultScreen(
            candidateId: candidateId,
            status: newStatus,
          ),
        ),
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Mock Candidate'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Candidate Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'First Name',
                      onSaved: (value) => _candidate.firstName = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'First name is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Last Name',
                      onSaved: (value) => _candidate.lastName = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Last name is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Email Address',
                      onSaved: (value) => _candidate.email = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Email is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Phone Number',
                      onSaved: (value) => _candidate.phone = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Phone number is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Work Location (Country, State)',
                      onSaved: (value) => _candidate.workLocation = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Work location is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Custom ID',
                      onSaved: (value) => _candidate.customId = value ?? '',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Custom ID is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: const Text(
                        'Create Mock Candidate',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required void Function(String?) onSaved,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
