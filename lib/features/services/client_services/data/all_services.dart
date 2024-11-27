import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class AllServicesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Task>> getServicesByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Incluye el ID del documento como `taskId`
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['taskId'] = doc.id; // Agrega el ID del documento
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Error loading services: $e');
    }
  }
}

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getClientData(String userId) async {
    try {
      final clientDoc =
          await _firestore.collection('clients').doc(userId).get();

      if (clientDoc.exists) {
        return clientDoc.data(); // Devuelve los datos del cliente
      } else {
        return null; // Retorna null si el cliente no existe
      }
    } catch (e) {
      throw Exception('Error fetching client data: $e');
    }
  }
}
