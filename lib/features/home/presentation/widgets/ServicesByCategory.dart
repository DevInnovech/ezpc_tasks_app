import 'package:ezpc_tasks_app/features/services/client_services/data/all_services.dart';
import 'package:ezpc_tasks_app/features/services/client_services/widgets/servicecard.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

//anulada temporarl
class ServicesByCategoryScreen extends StatefulWidget {
  final Category category;

  const ServicesByCategoryScreen({super.key, required this.category});

  @override
  _ServicesByCategoryScreenState createState() =>
      _ServicesByCategoryScreenState();
}

class _ServicesByCategoryScreenState extends State<ServicesByCategoryScreen> {
  late Future<List<Task>> _servicesFuture;
  bool _isGrid = false; // Comenzamos con lista (false)
  final bool _sortBySelectedTasks =
      true; // Por defecto ordenamos por selectedTasks

  @override
  void initState() {
    super.initState();
    _servicesFuture = AllServicesRepository()
        .getServicesByCategory(widget.category.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight;
    if (_isGrid) {
      imageHeight = 120.0; // Modo grid: imagen más pequeña
    } else {
      imageHeight = 160.0; // Modo lista: imagen más grande
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_agenda : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          )
        ],
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

            // Ordenar primero por averageRating y luego por selectedTasks
            services.sort((a, b) {
              final double aRating = double.tryParse(a.averageRating) ?? 0.0;
              final double bRating = double.tryParse(b.averageRating) ?? 0.0;
              if (bRating.compareTo(aRating) == 0) {
                final int aSelected = a.selectedTasks.length;
                final int bSelected = b.selectedTasks.length;
                return bSelected
                    .compareTo(aSelected); // Orden por selectedTasks
              }
              return bRating.compareTo(aRating); // Orden por averageRating
            });

            if (_isGrid) {
              // Modo Grid
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.3, // Ajusta según tus necesidades
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final task = services[index];
                  return ServiceCard(
                    task: task,
                    imageHeight: 120.0, // Imagen más pequeña en grid
                  );
                },
              );
            } else {
              // Modo Lista
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final task = services[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ServiceCard(
                      task: task,
                      imageHeight: 160.0, // Imagen más grande en lista
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(child: Text('No services found.'));
          }
        },
      ),
    );
  }
}
