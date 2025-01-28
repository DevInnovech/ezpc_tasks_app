import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CheckrService {
  static const String apiKey = "c4b4376f1dacdd9a16002e23ce97dd870e1714d1";
  static const String baseUrl = "https://api.checkr-staging.com/v1";

  static Map<String, String> get _headers {
    final basicAuth = base64Encode(utf8.encode('$apiKey:'));
    return {
      "Authorization": "Basic $basicAuth",
      "Content-Type": "application/json",
    };
  }

  static Future<void> listenToBackgroundChecks() async {
    FirebaseFirestore.instance
        .collection('background_checks')
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          final docId = change.doc.id;

          if (data != null) {
            String? candidateId = data['candidate_id'];

            // Crear un candidato si no existe
            if (candidateId == null) {
              candidateId = await createCandidate({
                "first_name": data['first_name'],
                "last_name": data['last_name'],
                "email": data['email'],
                "phone": data['phone'],
              });

              if (candidateId != null) {
                // Actualizar Firestore con el ID del candidato
                await FirebaseFirestore.instance
                    .collection('background_checks')
                    .doc(docId)
                    .update({'candidate_id': candidateId});
              } else {
                // Si no se puede crear el candidato, actualizar con error
                await FirebaseFirestore.instance
                    .collection('background_checks')
                    .doc(docId)
                    .update({'status': 'candidate_creation_failed'});
                continue;
              }
            }

            // Crear una invitación si aún no existe
            if (data['invitation_url'] == null) {
              final invitationUrl = await createDirectInvitation(candidateId);

              if (invitationUrl != null) {
                await FirebaseFirestore.instance
                    .collection('background_checks')
                    .doc(docId)
                    .update({
                  'invitation_url': invitationUrl,
                  'status': 'invitation_created',
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('background_checks')
                    .doc(docId)
                    .update({'status': 'invitation_failed'});
              }
            }
          }
        }
      }
    });
  }

  static Future<String?> createCandidate(
      Map<String, dynamic> candidateData) async {
    final url = Uri.parse("$baseUrl/candidates");

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(candidateData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Candidate created: $data");
        return data['id'];
      } else {
        print("Error creating candidate: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<String?> createDirectInvitation(String candidateId) async {
    final url = Uri.parse("$baseUrl/invitations");

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          "candidate_id": candidateId,
          "package": "test_pro_criminal",
          "communication_types": ["email"],
          "notification_settings": {"send_emails": true},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Invitation created: $data");
        return data['invitation_url']; // Return the invitation URL
      } else {
        print("Error creating invitation: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<String> checkInvitationStatus(String candidateId) async {
    final url = Uri.parse("$baseUrl/candidates/$candidateId");

    try {
      final response = await http.get(
        url,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Candidate status: $data");
        return data['status'] ?? "unknown";
      } else {
        print("Error fetching status: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Error: $e");
      return "error";
    }
  }
}
