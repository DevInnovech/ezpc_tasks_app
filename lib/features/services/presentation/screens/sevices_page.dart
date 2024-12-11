import 'package:ezpc_tasks_app/features/services/data/CreateCategoryScreen.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/task_details_screen.dart';
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
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);

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
          // Botones "Add New Task" y "Add New Category"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Botón "Add New Task"
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Color(0xFF404C8C)),
                    label: const Text(
                      'Add New Task',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF404C8C),
                        width: 2.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20.0),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/addNewServiceScreen');
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                // Botón "Add New Category"
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.category, color: Colors.orange),
                    label: const Text(
                      'Add New Category',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.orange,
                        width: 2.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCategoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: taskState.isLoading
                ? const LoadingWidget()
                : taskState.error != null
                    ? FetchErrorText(text: taskState.error!)
                    : (taskState.tasks.isEmpty ?? true)
                        ? _buildEmptyState()
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

  Widget _buildTaskCard(
      Task task, TaskNotifier taskNotifier, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Imagen de la tarea
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: CustomImage(
                  url: null,
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  path: task.imageUrl.isNotEmpty
                      ? task.imageUrl
                      : KImages.emptyBookingImage,
                ),
              ),
              // Estado de la tarea
              Positioned(
                top: 10.0,
                left: 10.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0),
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
                    final shouldDelete =
                        await _showDeleteConfirmationDialog(context);
                    if (shouldDelete) {
                      await taskNotifier.deleteTask(task);
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
                _buildCategoryTag(task.category),
                const SizedBox(height: 8.0),
                CustomText(
                  text: task.taskName,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4.0),
                CustomText(
                  text: DateFormat.yMMMMd().format(
                      DateTime.tryParse(task.issueDate) ?? DateTime.now()),
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4.0),
                CustomText(
                  text: '\$${task.price}',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                const SizedBox(height: 10.0),
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
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16.0),
                ),
              ),
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

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(
            path: KImages.emptyBookingImage,
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
