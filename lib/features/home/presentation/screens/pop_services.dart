import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_bottom_navigation_bar.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksByServiceScreen extends StatefulWidget {
  final String serviceName; // Name of the service to filter tasks by

  const TasksByServiceScreen({
    super.key,
    required this.serviceName,
  });

  @override
  _TasksByServiceScreenState createState() => _TasksByServiceScreenState();
}

class _TasksByServiceScreenState extends State<TasksByServiceScreen> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _getTasksByService(widget.serviceName);
  }

  /// Fetch tasks filtered by the selected service name in `selectedTasks`
  Future<List<Task>> _getTasksByService(String serviceName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get(); // Get all tasks and filter manually

      // Filtrar manualmente las tareas que contienen el servicio en `selectedTasks`
      final filteredTasks = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final selectedTasks = data['selectedTasks'] as Map<String, dynamic>?;

        // Comprobar si el servicio existe en `selectedTasks`
        return selectedTasks != null && selectedTasks.containsKey(serviceName);
      }).toList();

      return filteredTasks.map((doc) {
        final data = doc.data();
        data['taskId'] = doc.id; // Agregar el ID del documento como taskId
        return Task.fromMap(data); // Convertir datos al modelo Task
      }).toList();
    } catch (e) {
      throw Exception('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Tasks by Service'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Showing results for "${widget.serviceName}"',
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
                    child: Text('Error loading tasks: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks found for this service.'),
                    );
                  }

                  // Display tasks in a list
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ServiceCard(
                          task: task, // Pass task to ServiceCard widget
                          imageHeight: 160.0, // Ensure consistent design
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No tasks found.'));
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClientBottomNavigationBar(scaffoldKey: scaffoldKey),
    );
  }
}
