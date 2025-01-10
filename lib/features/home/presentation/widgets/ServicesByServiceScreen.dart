import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesByServiceScreen extends StatefulWidget {
  final String serviceName; // Nombre del servicio a buscar

  const ServicesByServiceScreen({
    super.key,
    required this.serviceName,
  });

  @override
  _ServicesByServiceScreenState createState() =>
      _ServicesByServiceScreenState();
}

class _ServicesByServiceScreenState extends State<ServicesByServiceScreen> {
  late Future<List<Task>> _tasksFuture;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _getTasksByService(widget.serviceName);
  }

  // Método para obtener las tareas desde Firestore por servicio
  Future<List<Task>> _getTasksByService(String serviceName) async {
    try {
      // Obtener todas las tareas activas
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: 1) // Solo tareas activas
          .get();

      // Filtrar tareas por servicios dentro de selectedTasks
      return querySnapshot.docs.where((doc) {
        final selectedTasks =
            Map<String, dynamic>.from(doc['selectedTasks'] ?? {});
        return selectedTasks
            .containsKey(serviceName); // Filtrar por el servicio
      }).map((doc) {
        Map<String, dynamic> data = doc.data();
        data['taskId'] = doc.id; // Agregar el ID del documento como taskId
        return Task.fromMap(data); // Convertir los datos al modelo Task
      }).toList();
    } catch (e) {
      throw Exception('Error al cargar las tareas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas para el Servicio: ${widget.serviceName}'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las tareas: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return Center(
                child: Text(
                    'No se encontraron tareas para el servicio ${widget.serviceName}.'),
              );
            }

            // Mostrar tareas en lista
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ServiceCard(
                    task: task,
                    imageHeight: 160.0, // Diseño consistente
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No se encontraron tareas.'));
          }
        },
      ),
    );
  }
}
