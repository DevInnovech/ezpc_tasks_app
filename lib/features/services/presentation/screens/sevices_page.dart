import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/task_details_screen.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/services_appbar.dart';
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
    final taskNotifier = ref.read(taskProvider.notifier); // Acceder al notifier

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
                                  ? _buildTaskCard(task, taskNotifier, context)
                                  : const SizedBox.shrink();
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la tarjeta de cada tarea
  Widget _buildTaskCard(
      Task task, TaskNotifier taskNotifier, BuildContext context) {
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
                      : KImages.emptyBookingImage, // URL de la imagen
                ),
              ),
              // Estado de la tarea (Activo por defecto)
              Positioned(
                top: 10.0,
                left: 10.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    // Asignar todos los tasks como "Active" por defecto
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Botón de eliminación
              Positioned(
                top: 10.0,
                right: 10.0,
                child: GestureDetector(
                  onTap: () async {
                    // Mostrar el cuadro de diálogo de confirmación de eliminación
                    final shouldDelete =
                        await _showDeleteConfirmationDialog(context);
                    if (shouldDelete) {
                      await taskNotifier.deleteTask(task); // Eliminar tarea
                    }
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
                // Mostrar categoría
                _buildCategoryTag(task.category),
                const SizedBox(height: 8.0),
                // Mostrar subcategoría
                CustomText(
                  text: task.subCategory,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4.0),
                // Mostrar fecha de creación
                CustomText(
                  text: DateFormat.yMMMMd()
                      .format(DateTime.parse(task.issueDate)),
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4.0),
                // Mostrar precio
                CustomText(
                  text: '\$${task.price}',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                const SizedBox(height: 10.0),
                // Botón "View Details" con ajuste de tamaño y estilo
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsScreen(task: task),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 20.0,
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar el diálogo de confirmación de eliminación
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(fontSize: 16.0),
            ),
            actions: [
              // Botón "Cancel" en azul
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16.0),
                ),
              ),
              // Botón "Delete" en rojo
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
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
