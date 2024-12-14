import 'package:ezpc_tasks_app/features/services/client_services/data/all_services.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class ServicesByCategoryScreens2 extends StatefulWidget {
  final Category category;

  const ServicesByCategoryScreens2({super.key, required this.category});

  @override
  _ServicesByCategoryScreens2State createState() =>
      _ServicesByCategoryScreens2State();
}

class _ServicesByCategoryScreens2State
    extends State<ServicesByCategoryScreens2> {
  late Future<List<Task>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture =
        AllServicesRepository().getServicesByCategory(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Task>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Error loading services: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final services = snapshot.data!;
            if (services.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'No tasks available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: services.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final task = services[index];
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: ServiceCard(
                    task: task,
                    imageHeight: 120,
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'No services found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
