import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor del repositorio de tareas
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// Repositorio de Tareas para interactuar con Firestore
class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para guardar una tarea en Firebase (siempre creando una nueva)
  Future<void> saveTask(Task task) async {
    try {
      Map<String, dynamic> taskData = task.toMap();

      // Validación para evitar nulls en Firebase
      taskData.removeWhere((key, value) => value == null || value == '');

      // Guardar la tarea con un nuevo documento en la colección 'tasks'
      await _firestore.collection('tasks').doc(task.id).set(taskData);
      print('Task saved successfully');
    } catch (e) {
      print('Error saving task to Firebase: $e');
      rethrow;
    }
  }

  // Método para eliminar una tarea de Firebase (si se necesita en el futuro)
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

Future<void> deleteTask(String taskId) async {
  try {
    // Aquí va la lógica de eliminación. Si estás usando Firestore, sería algo como:
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    debugPrint('Tarea con ID: $taskId eliminada de la base de datos.');
  } catch (e) {
    debugPrint('Error al eliminar la tarea con ID: $taskId -> $e');
    throw Exception('No se pudo eliminar la tarea.');
  }
}
