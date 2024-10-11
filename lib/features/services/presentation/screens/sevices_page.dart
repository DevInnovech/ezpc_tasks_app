import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado de las tareas utilizando Riverpod
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        centerTitle: true,
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Botón "Add New Task" siempre visible en la parte superior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Color(0xFF404C8C)),
              label: const Text(
                'Add New Task',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF404C8C), // Borde del color especificado
                  width: 2.0, // Grosor del borde
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
              ),
              onPressed: () {
                // Navegar a la pantalla de agregar nueva tarea
                Navigator.pushNamed(context, '/addNewServiceScreen');
              },
            ),
          ),
          Expanded(
            child: taskState.isLoading
                ? const LoadingWidget()
                : taskState.error != null
                    ? FetchErrorText(text: taskState.error!)
                    : (taskState.tasks.isEmpty ?? true)
                        ? _buildEmptyState() // Estado vacío con imagen y mensaje
                        : ListView.builder(
                            itemCount: taskState.tasks.length ?? 0,
                            itemBuilder: (context, index) {
                              final task = taskState.tasks[index];
                              return task != null
                                  ? _buildTaskCard(task)
                                  : const SizedBox.shrink();
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la tarjeta de cada tarea
  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Imagen de la tarea
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: CustomImage(
                  url: null,
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  path: task.imageUrl.isNotEmpty
                      ? task.imageUrl
                      : KImages
                          .emptyBookingImage, // Aquí pasamos la URL de la imagen guardada correctamente
                ),
              ),
              // Estado de la tarea (Activo/Eliminado)
              Positioned(
                top: 10.0,
                left: 10.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: task.requiresLicense ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    task.requiresLicense ? 'Active' : 'Inactive',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Botón de eliminación
              Positioned(
                top: 10.0,
                right: 10.0,
                child: GestureDetector(
                  onTap: () {
                    // Lógica para eliminar la tarea
                  },
                  child:
                      const Icon(Icons.delete, color: Colors.red, size: 28.0),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría y subcategoría
                Row(
                  children: [
                    _buildCategoryTag(task.category),
                    const SizedBox(width: 10.0),
                    _buildCategoryTag(task.subCategory),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Nombre de la tarea (Sin preguntas)
                CustomText(
                  text: _cleanTaskName(task
                      .name), // Limpieza de `task.name` para eliminar preguntas
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4.0),
                // Fecha de creación
                CustomText(
                  text: DateFormat.yMMMMd()
                      .format(DateTime.parse(task.issueDate)),
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4.0),
                // Precio de la tarea
                CustomText(
                  text: '\$${task.price}',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                const SizedBox(height: 10.0),
                // Botón de detalles
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica para ver detalles de la tarea
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 12.0),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para limpiar el nombre de la tarea eliminando las preguntas
  String _cleanTaskName(String name) {
    // Suprimir preguntas y respuestas del campo `name`
    final cleanedName =
        name.split('\n').first; // Tomar solo la primera línea del nombre
    return cleanedName.trim();
  }

  // Método para construir las etiquetas de categoría y subcategoría
  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12.0, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  // Método para construir el estado vacío
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(
            path: KImages.emptyBookingImage, // Imagen de estado vacío
            url: null,
          ),
          SizedBox(height: 20.0),
          CustomText(
            text: 'No Services Available',
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
