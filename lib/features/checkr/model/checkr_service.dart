class MockCheckrService {
  static final Map<String, Map<String, String>> mockCandidates = {
    "Homer Simpson": {"id": "mock_1", "status": "Clear"},
    "Jennifer Aniston": {"id": "mock_2", "status": "Consider"},
    "Vito Andolini": {"id": "mock_3", "status": "Canceled"},
  };

  static Future<Map<String, String>?> createCandidate(
      Map<String, String> data) async {
    final name = "${data['first_name']} ${data['last_name']}";
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return mockCandidates[name];
  }
}
