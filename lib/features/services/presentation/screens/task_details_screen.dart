import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de cabecera
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  task.imageUrl,
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Título del task y precio en una fila
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.subCategory,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${task.price}',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            task.averageRating.toString(),
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Sección de descripción
              _buildSectionTitle('Description'),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16.0),

              // Sección de "Questions"
              if (task.questionResponses != null &&
                  task.questionResponses!.isNotEmpty) ...[
                _buildSectionTitle('FAQs'),
                ...task.questionResponses!.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
              const SizedBox(height: 16.0),

              // Sección de "Working Hours"
              _buildSectionTitle('Working Hours'),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF404C8C)),
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: task.workingHours.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16.0, color: Color(0xFF404C8C)),
                          const SizedBox(width: 10.0),
                          Text(
                            '${entry.key}: ${entry.value['start']} - ${entry.value['end']}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20.0),

              // Sección de "Reviews"
              _buildSectionTitle('Reviews (1)'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(task.imageUrl ??
                        'https://via.placeholder.com/150'), // Placeholder si no hay imagen
                  ),
                  title: Text(
                    task.clientName ?? 'Anonymous',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    task.createdAt ?? '',
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20.0),
                      Text(
                        task.averageRating.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      // Botones de acción en la parte inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón "Activate/Inactivate"
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      task.requiresLicense ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  task.requiresLicense ? 'Inactivate' : 'Activate',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16.0),

            // Botón "Edit Service"
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica de edición de la tarea (por implementar)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Edit Service',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir el título de cada sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF404C8C), // Color modificado
        ),
      ),
    );
  }
}
