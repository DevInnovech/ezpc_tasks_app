import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor del repositorio de tareas
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// Repositorio de Tareas para interactuar con Firestore
class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para guardar una tarea en Firebase
  Future<void> saveTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toMap());
      print('Task saved successfully');
    } catch (e) {
      print('Error saving task to Firebase: $e');
      rethrow;
    }
  }

  // Método para actualizar una tarea existente en Firebase
  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
      print('Task updated successfully');
    } catch (e) {
      print('Error updating task in Firebase: $e');
      rethrow;
    }
  }

  // Método para eliminar una tarea de Firebase
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task from Firebase: $e');
      rethrow;
    }
  }

  // Método para cargar todas las tareas desde Firebase
  Future<List<Task>> getTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting tasks from Firebase: $e');
      rethrow;
    }
  }
}
