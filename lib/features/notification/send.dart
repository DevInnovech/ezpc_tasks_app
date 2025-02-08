import 'package:ezpc_tasks_app/features/notification/generekey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendNotification {
  static Future<void> sendNotificationToUser(String userToken, String title,
      String body, Map<String, dynamic>? data) async {
    //GetServerKey getServeKey = GetServerKey();

    String serverKey = "await getServeKey.getServerKeyToken() ";
    print(serverKey);
    final Uri url = Uri.parse(
        "https://fcm.googleapis.com/v1/projects/ezpc-tasks/messages:send");

    var headers = <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Bearer $serverKey",
    };
    Map<String, dynamic> message = {
      "message": {
        "token": userToken,
        "notification": {"title": title, "body": body},
        "data": data
      }
    };

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("✅ Notificación enviada con éxito.");
    } else {
      print("❌ Error al enviar la notificación: ${response.body}");
    }
  }
}
