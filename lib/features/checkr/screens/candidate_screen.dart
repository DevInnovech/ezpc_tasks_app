import 'package:ezpc_tasks_app/features/checkr/model/candidate.dart';
import 'package:ezpc_tasks_app/features/checkr/data/moc_data/moc_check_service.dart';
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
    dob: '',
    ssn: '',
  );

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result =
          await MockCheckrService.createCandidate(_candidate.toJson());
      if (result != null) {
        print('Candidato creado: $result');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Candidato creado con éxito')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear candidato')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Candidato')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _candidate.firstName = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                onSaved: (value) => _candidate.lastName = value ?? '',
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                onSaved: (value) => _candidate.email = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => _candidate.phone = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento (YYYY-MM-DD)'),
                onSaved: (value) => _candidate.dob = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'SSN (Mock)'),
                onSaved: (value) => _candidate.ssn = value ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Crear Candidato'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
