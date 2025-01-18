class MockCheckrService {
  // Lista de candidatos simulados
  static final List<Map<String, dynamic>> mockCandidates = [
    {
      "first_name": "Homer",
      "last_name": "Simpson",
      "email": "homer.simpson@example.com",
      "phone": "555-123-4567",
      "work_location": "San Jose, CA",
      "custom_id": "mock_1",
      "result": "Clear"
    },
    {
      "first_name": "Jennifer",
      "last_name": "Aniston",
      "email": "jennifer.aniston@example.com",
      "phone": "555-987-6543",
      "work_location": "San Jose, CA",
      "custom_id": "mock_2",
      "result": "Consider"
    },
    {
      "first_name": "Vito",
      "last_name": "Andolini",
      "email": "vito.andolini@example.com",
      "phone": "555-543-2168",
      "work_location": "Newark, NJ",
      "custom_id": "mock_3",
      "result": "Canceled"
    }
  ];

  // Método para buscar un candidato simulado
  static Future<Map<String, dynamic>?> createCandidate(
      Map<String, String> data) async {
    await Future.delayed(
        const Duration(seconds: 1)); // Simula un retraso de red

    try {
      final candidate = mockCandidates.firstWhere(
        (candidate) =>
            candidate['first_name'] == data['first_name'] &&
            candidate['last_name'] == data['last_name'] &&
            candidate['custom_id'] == data['custom_id'],
      );

      return candidate; // Retorna el candidato o null
    } catch (e) {
      return null; // En caso de error, retorna null
    }
  }

  // Método para simular la actualización de estado basado en mock data
  static Future<void> simulateStatusUpdate(
      String candidateId, Function(String) onStatusUpdated) async {
    await Future.delayed(
        const Duration(seconds: 5)); // Simula un retraso de actualización

    // Busca el candidato en el mock data
    final candidate = mockCandidates.firstWhere(
      (candidate) => candidate['custom_id'] == candidateId,
    );

    final status = candidate['result']
        as String; // Obtiene el estado definido en el mock data
    onStatusUpdated(status); // Llama al callback con el estado correspondiente
  }
}
