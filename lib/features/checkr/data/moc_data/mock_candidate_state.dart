import 'package:flutter/material.dart';

class MockCandidateState with ChangeNotifier {
  final List<Map<String, String>> _candidates = [];

  List<Map<String, String>> get candidates => _candidates;

  void addCandidate(Map<String, String> candidate) {
    _candidates.add(candidate);
    notifyListeners();
  }

  void updateCandidateStatus(String candidateId, String newStatus) {
    final candidate = _candidates.firstWhere((c) => c['id'] == candidateId);
    candidate['status'] = newStatus;
    notifyListeners();
  }
}
