import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:uuid/uuid.dart';
import 'package:ezpc_tasks_app/features/services/data/task_repository.dart';
import 'package:flutter/foundation.dart'; // Para logging más adecuado

// Proveedor del TaskNotifier
final taskProvider = StateNotifierProvider<TaskNotifier, Task?>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});

class TaskNotifier extends StateNotifier<Task?> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(null);

  // Método para actualizar el estado de la tarea
  void updateTask(Task Function(Task?) updater) {
    final updatedTask = updater(state);
    if (updatedTask != null) {
      state = _ensureAllFieldsFilled(updatedTask);
    }
  }

  // Asegurarse de que todos los campos estén llenos
  Task _ensureAllFieldsFilled(Task task) {
    return task.copyWith(
      id: task.id.isNotEmpty ? task.id : const Uuid().v4(),
      name: task.name.isNotEmpty ? task.name : state?.name ?? '',
      category:
          task.category.isNotEmpty ? task.category : state?.category ?? '',
      subCategory: task.subCategory.isNotEmpty
          ? task.subCategory
          : state?.subCategory ?? '',
      price: task.price > 0 ? task.price : state?.price ?? 0.0,
      imageUrl:
          task.imageUrl.isNotEmpty ? task.imageUrl : state?.imageUrl ?? '',
      requiresLicense: task.requiresLicense,
      licenseType: task.licenseType.isNotEmpty
          ? task.licenseType
          : state?.licenseType ?? '',
      licenseNumber: task.licenseNumber.isNotEmpty
          ? task.licenseNumber
          : state?.licenseNumber ?? '',
      licenseExpirationDate: task.licenseExpirationDate.isNotEmpty
          ? task.licenseExpirationDate
          : state?.licenseExpirationDate ?? '',
      workingDays: task.workingDays != null && task.workingDays!.isNotEmpty
          ? task.workingDays
          : state?.workingDays ?? [],
      workingHours: task.workingHours != null && task.workingHours!.isNotEmpty
          ? task.workingHours
          : state?.workingHours ?? {},
      specialDays: task.specialDays != null && task.specialDays!.isNotEmpty
          ? task.specialDays
          : state?.specialDays ?? [],
    );
  }

  // Método para guardar una tarea
  Future<void> saveTask(Task task) async {
    try {
      final taskToSave = _ensureAllFieldsFilled(task);
      await _repository.saveTask(taskToSave);
      state = taskToSave;
      if (kDebugMode) {
        print('Task saved successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving task: $e\n$stackTrace');
      rethrow;
    }
  }

  // Método para resetear la tarea
  void resetTask() {
    state = null;
  }

  // Método para actualizar la categoría
  void setCategory(String category) {
    updateTask((task) => (task ??
            Task(
              id: '',
              name: '',
              category: category,
              subCategory: '',
              price: 0.0,
              imageUrl: '',
              requiresLicense: false,
              licenseType: '',
              licenseNumber: '',
              licenseExpirationDate: '',
              workingDays: const [],
              workingHours: const {},
              specialDays: const [],
            ))
        .copyWith(category: category));
  }

  // Métodos adicionales para actualizar otros campos
  void setName(String name) {
    updateTask((task) {
      return (task ?? _createEmptyTask()).copyWith(name: name);
    });
  }

  void setPrice(double price) {
    updateTask((task) {
      return (task ?? _createEmptyTask()).copyWith(price: price);
    });
  }

  // Método privado para crear una tarea vacía
  Task _createEmptyTask() {
    return const Task(
      id: '',
      name: '',
      category: '',
      subCategory: '',
      price: 0.0,
      imageUrl: '',
      requiresLicense: false,
      licenseType: '',
      licenseNumber: '',
      licenseExpirationDate: '',
      workingDays: [],
      workingHours: {},
      specialDays: [],
    );
  }
}
