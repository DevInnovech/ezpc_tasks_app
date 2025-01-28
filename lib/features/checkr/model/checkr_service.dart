import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CheckrService {
  static const String apiKey = "f9c5facefa8105057080d2ef94551f5ccd05034c";
  static const String baseUrl = "https://api.checkr-staging.com/v1";

  static Map<String, String> get _headers {
    final basicAuth = base64Encode(utf8.encode('$apiKey:'));
    return {
      "Authorization": "Basic $basicAuth",
      "Content-Type": "application/json",
    };
  }

  static Future<Map<String, dynamic>?> createCandidateAndSendInvitation(
      Map<String, dynamic> candidateData) async {
    try {
      // Validate work_locations before sending the request
      if (candidateData['work_locations'] == null ||
          !(candidateData['work_locations'] is List) ||
          (candidateData['work_locations'] as List).isEmpty) {
        return {
          'success': false,
          'error': 'work_locations is required and must be a non-empty list'
        };
      }

      final Map<String, dynamic> checkrCandidateData = {
        "first_name": candidateData['first_name'],
        "last_name": candidateData['last_name'],
        "email": candidateData['email'],
        "phone": candidateData['phone'],
        "zipcode": candidateData['zipcode'],
        "work_locations":
            candidateData['work_locations'], // Ensure it's passed correctly
        "no_middle_name": true,
        "copy_requested": true,
      };

      print(
          "Sending candidate data to Checkr: ${json.encode(checkrCandidateData)}");

      final candidateId = await createCandidate(checkrCandidateData);

      if (candidateId == null) {
        return {'success': false, 'error': 'Failed to create candidate'};
      }

      final invitationUrl = await retryCreateDirectInvitation(
          candidateId, candidateData['work_locations'], 3);

      if (invitationUrl == null) {
        return {
          'success': false,
          'error': 'Failed to create invitation after retries',
          'candidateId': candidateId
        };
      }

      return {
        'success': true,
        'candidateId': candidateId,
        'invitationUrl': invitationUrl
      };
    } catch (e) {
      print("Error in createCandidateAndSendInvitation: $e");
      return {'success': false, 'error': e.toString()};
    }
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

  static Future<String?> createDirectInvitation(
      String candidateId, List<Map<String, String>> workLocations) async {
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
          "work_locations": workLocations, // Pass work_locations explicitly
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Invitation created: $data");
        return data['invitation_url'];
      } else {
        print("Error creating invitation: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<String?> retryCreateDirectInvitation(String candidateId,
      List<Map<String, String>> workLocations, int retries) async {
    String? invitationUrl;
    for (int attempt = 1; attempt <= retries; attempt++) {
      print("Retrying invitation creation... Attempt $attempt/$retries");
      invitationUrl = await createDirectInvitation(candidateId, workLocations);
      if (invitationUrl != null) break;
      await Future.delayed(const Duration(seconds: 2));
    }
    return invitationUrl;
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

  static Future<void> updateBackgroundCheckStatus(String candidateId) async {
    final url = Uri.parse("$baseUrl/candidates/$candidateId");

    try {
      final response = await http.get(
        url,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] ?? 'unknown';

        print("Candidate status updated: $status");

        await FirebaseFirestore.instance
            .collection('background_checks')
            .doc(candidateId)
            .update({
          'status': status,
          'updated_at': Timestamp.now(),
        });
      } else {
        print("Error fetching candidate status: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
