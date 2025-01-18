import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesByProviderScreen extends StatefulWidget {
  final String providerName; // Nombre del proveedor seleccionado
  final String providerLastName; // Apellido del proveedor seleccionado
  final String providerDocumentID; // ID del documento del proveedor

  const ServicesByProviderScreen({
    super.key,
    required this.providerName,
    required this.providerLastName,
    required this.providerDocumentID,
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
    _tasksFuture = _getTasksByProvider(widget.providerDocumentID);
  }

  // Método para obtener las tareas desde Firestore
  Future<List<Task>> _getTasksByProvider(String providerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('providerId', isEqualTo: providerId) // Filtrar por providerId
          .where('status', isEqualTo: 1) // Solo servicios activos
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['taskId'] = doc.id; // Agregar el ID del documento como taskId

        // Convertir selectedTasks al formato adecuado si está presente
        if (data['selectedTasks'] != null) {
          data['selectedTasks'] =
              Map<String, dynamic>.from(data['selectedTasks']);
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Mostrando los resultados de ${widget.providerName} ${widget.providerLastName}',
              style: const TextStyle(
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
                    return Center(
                      child: Text(
                          'No se encontraron tareas para ${widget.providerName} ${widget.providerLastName}.'),
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
