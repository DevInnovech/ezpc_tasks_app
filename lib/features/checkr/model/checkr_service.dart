import 'dart:convert';
import 'package:http/http.dart' as http;

/*
class CheckrService {
  static const String _baseUrl = 'https://api.checkr.com/v1';
  static const String _apiKey = 'YOUR_API_KEY'; // Sustituye con tu clave API

  static Map<String, String> _headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // Crear candidato
  static Future<Map<String, dynamic>?> createCandidate(Map<String, dynamic> candidateData) async {
    final url = Uri.parse('$_baseUrl/candidates');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(candidateData),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error al crear candidato: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
      return null;
    }
  }

  // Crear invitación
  static Future<Map<String, dynamic>?> createInvitation(String candidateId) async {
    final url = Uri.parse('$_baseUrl/invitations');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'candidate_id': candidateId}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error al crear invitación: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
      return null;
    }
  }

  // Obtener estado de la invitación
  static Future<Map<String, dynamic>?> getInvitationStatus(String invitationId) async {
    final url = Uri.parse('$_baseUrl/invitations/$invitationId');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error al obtener estado: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
      return null;
    }
  }
}

*/