import 'package:ezpc_tasks_app/features/home/presentation/widgets/client_bottom_navigation_bar.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesByProviderScreen extends StatefulWidget {
  final String providerId; // Provider ID

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
  late Future<String> _providerNameFuture;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _getTasksByProvider(widget.providerId);
    _providerNameFuture = _getProviderName(widget.providerId);
  }

  Future<List<Task>> _getTasksByProvider(String providerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('providerId', isEqualTo: providerId)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['taskId'] = doc.id; // Add document ID as taskId

        // Convert selectedTasks to the correct format if present
        if (data['selectedTasks'] != null) {
          data['selectedTasks'] =
              Map<String, dynamic>.from(data['selectedTasks']);
        }

        return Task.fromMap(data); // Convert data to Task model
      }).toList();
    } catch (e) {
      throw Exception('Error loading tasks: $e');
    }
  }

  Future<String> _getProviderName(String providerId) async {
    try {
      final providerDoc =
          await _firestore.collection('providers').doc(providerId).get();

      if (providerDoc.exists) {
        final providerData = providerDoc.data();
        return providerData?['name'] ?? 'Unknown Provider';
      } else {
        return 'Unknown Provider';
      }
    } catch (e) {
      return 'Error retrieving provider name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Featured Suppliers'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _providerNameFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Loading provider name...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                final providerName = snapshot.data ?? 'Unknown Provider';
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Showing tasks for $providerName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
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
                      child: Text('No tasks found for this provider.'),
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
