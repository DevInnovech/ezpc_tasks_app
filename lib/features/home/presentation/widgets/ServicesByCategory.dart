import 'package:ezpc_tasks_app/features/services/client_services/data/all_services.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class ServicesByCategoryScreen extends StatefulWidget {
  final Category category;

  const ServicesByCategoryScreen({super.key, required this.category});

  @override
  _ServicesByCategoryScreenState createState() =>
      _ServicesByCategoryScreenState();
}

class _ServicesByCategoryScreenState extends State<ServicesByCategoryScreen> {
  late Future<List<Task>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = AllServicesRepository()
        .getServicesByCategory(widget.category.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: FutureBuilder<List<Task>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading services: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final services = snapshot.data!;
            if (services.isEmpty) {
              return const Center(child: Text('No tasks available.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final task = services[index];
                return ServiceCard(task: task);
              },
            );
          } else {
            return const Center(child: Text('No services found.'));
          }
        },
      ),
    );
  }
}
