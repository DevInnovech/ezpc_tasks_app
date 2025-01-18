import 'package:flutter/material.dart';

class CandidateResultScreen extends StatelessWidget {
  final String candidateId;
  final String status;

  const CandidateResultScreen({
    required this.candidateId,
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Candidate Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Candidate ID: $candidateId',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Final Status: $status', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
