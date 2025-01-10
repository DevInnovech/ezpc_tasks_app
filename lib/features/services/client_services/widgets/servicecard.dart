import 'package:ezpc_tasks_app/features/services/client_services/presentation/screens/Booking_Screen.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class ServiceCard extends StatelessWidget {
  final Task task;
  final double imageHeight;

  const ServiceCard({super.key, required this.task, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    // Verifica si selectedTasks no es nulo o vacío
    final selectedTasks = task.selectedTasks ?? {};

    if (selectedTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No services available for ${task.taskName}.',
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: selectedTasks.entries.map((entry) {
        final serviceName = entry.key;
        final price = entry.value;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Para separar contenido y botón
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: task.imageUrl.isNotEmpty
                    ? Image.network(
                        task.imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image,
                                size: 120, color: Colors.grey),
                          );
                        },
                      )
                    : const Placeholder(
                        fallbackHeight: 120,
                        fallbackWidth: double.infinity,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName, // Muestra el nombre del servicio
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(Icons.price_check,
                            size: 16.0, color: Colors.blue),
                        const SizedBox(width: 4.0),
                        Text(
                          '\$$price', // Muestra el precio del servicio
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16.0, color: Colors.orange),
                        const SizedBox(width: 4.0),
                        Text(
                          '${task.averageRating} (${task.totalReview})',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'by ${task.firstName ?? 'N/A'}', // Muestra el nombre del proveedor
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (task.collaborators != null &&
                            task.collaborators!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16.0, color: Colors.blue),
                              const SizedBox(width: 4.0),
                              Text(
                                '${task.collaborators!.length}', // Muestra la cantidad de colaboradores
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          taskId: task.id,
                          taskName: task
                              .taskName, // Pasa el nombre de la tarea seleccionada
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Book Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
