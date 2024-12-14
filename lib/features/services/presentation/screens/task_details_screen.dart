import 'package:ezpc_tasks_app/features/services/presentation/screens/edit_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late Task currentTask;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task; // Inicializamos con el `task` inicial
  }

  Future<void> _toggleTaskStatus() async {
    try {
      // Mostramos un estado de carga si es necesario
      setState(() {
        isLoading = true;
      });

      // Cambiamos el estado de la tarea localmente
      final newStatus = currentTask.status == 1 ? 0 : 1;

      // Actualizamos el estado en Firebase
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(currentTask.taskId)
          .update({'status': newStatus});

      // Recargamos la información actualizada desde Firebase
      final updatedTaskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(currentTask.taskId)
          .get();

      // Actualizamos el estado local con los datos obtenidos
      setState(() {
        currentTask = Task.fromMap({
          ...updatedTaskDoc.data()!,
          'taskId': updatedTaskDoc.id,
        });
        isLoading = false;
      });

      // Mostramos un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 1
              ? 'Task activated successfully'
              : 'Task deactivated successfully'),
          backgroundColor: newStatus == 1 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // Manejo de errores
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating task status'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error updating task status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de cabecera
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        currentTask.imageUrl,
                        width: double.infinity,
                        height: 200.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
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
                          currentTask.subCategory,
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
                              '\$${currentTask.price}',
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
                                  currentTask.averageRating.toString(),
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
                      currentTask.details,
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Sección de FAQs
                    if (currentTask.questionResponses != null &&
                        currentTask.questionResponses!.isNotEmpty) ...[
                      _buildSectionTitle('FAQs'),
                      ...currentTask.questionResponses!.entries.map((entry) {
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
                        children: currentTask.workingHours.entries.map((entry) {
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
            // Botón "Activate/Deactivate"
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _toggleTaskStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentTask.status == 1 ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  currentTask.status == 1 ? 'Deactivate' : 'Activate',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16.0), // Espacio entre los botones
            // Botón "Edit Service"
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de edición de servicio
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditServiceScreen(task: currentTask),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF404C8C),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Edit Task',
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
          color: Color(0xFF404C8C),
        ),
      ),
    );
  }
}
