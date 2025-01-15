import 'package:cloud_functions/cloud_functions.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> callCalculateAndUpdateProviderRating(String providerId) async {
  final url = Uri.parse(
      'https://us-central1-ezpc-tasks.cloudfunctions.net/calculateAndUpdateProviderRating');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'providerId': providerId, // Enviar el ID del proveedor
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${data['message']}');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

void onReviewAdded(String providerId) async {
  await callCalculateAndUpdateProviderRating(providerId);
  print('Provider rating calculation triggered.');
}
