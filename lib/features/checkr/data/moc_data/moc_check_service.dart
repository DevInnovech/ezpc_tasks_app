import 'dart:convert';

class MockCheckrService {
  // Simular la creación de un candidato
  static Future<Map<String, dynamic>?> createCandidate(
      Map<String, dynamic> candidateData) async {
    print(
        'Simulando la creación de un candidato con los datos: $candidateData');
    await Future.delayed(Duration(seconds: 2)); // Simula una espera
    return {
      'id': 'mock_candidate_id',
      'status': 'created',
      'data': candidateData,
    };
  }

  // Simular la creación de una invitación
  static Future<Map<String, dynamic>?> createInvitation(
      String candidateId) async {
    print(
        'Simulando la creación de una invitación para el candidato ID: $candidateId');
    await Future.delayed(Duration(seconds: 2));
    return {
      'id': 'mock_invitation_id',
      'status': 'invitation_sent',
      'candidate_id': candidateId,
    };
  }

  // Simular el estado de la invitación
  static Future<Map<String, dynamic>?> getInvitationStatus(
      String invitationId) async {
    print('Simulando el estado de la invitación con ID: $invitationId');
    await Future.delayed(Duration(seconds: 2));
    return {
      'id': invitationId,
      'status': 'pending',
    };
  }
}
