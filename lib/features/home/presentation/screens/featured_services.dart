import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesByProviderScreen extends StatefulWidget {
  final String providerId; // ID del proveedor

  const ServicesByProviderScreen({
    super.key,
    required this.providerId,
  });

  @override
  _ServicesByProviderScreenState createState() =>
      _ServicesByProviderScreenState();
}

class _ServicesByProviderScreenState extends State<ServicesByProviderScreen> {
  late Future<List<Task>> _tasksFuture;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _getTasksByProvider(widget.providerId);
  }

  // Método para obtener las tareas desde Firestore
  Future<List<Task>> _getTasksByProvider(String providerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('providerId', isEqualTo: providerId)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['taskId'] = doc.id; // Agregar el ID del documento como taskId

        // Procesar campos específicos como averageRating
        if (data['averageRating'] != null && data['averageRating'] is double) {
          data['averageRating'] = data['averageRating'].toString();
        }

        // Convertir selectedTasks al formato adecuado si está presente
        if (data['selectedTasks'] != null) {
          data['selectedTasks'] =
              Map<String, dynamic>.from(data['selectedTasks'])
                  .map((key, value) {
            // Convertir todo a String
            return MapEntry(key, value.toString());
          });
        }

        return Task.fromMap(data); // Convertir datos al modelo Task
      }).toList();
    } catch (e) {
      throw Exception('Error al cargar las tareas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas por Proveedor'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje dinámico
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mostrando tareas relacionadas al proveedor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Error al cargar las tareas: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return const Center(
                      child:
                          Text('No se encontraron tareas para este proveedor.'),
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
                          task: task, // Pasar la tarea al widget ServiceCard
                          imageHeight: 160.0, // Asegurar un diseño consistente
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No se encontraron tareas.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
