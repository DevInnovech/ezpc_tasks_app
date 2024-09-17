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

  void updateTask(Task Function(Task?) updater) {
    final updatedTask = updater(state);
    if (updatedTask != null) {
      state = _ensureAllFieldsFilled(updatedTask);
    }
  }

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
      issueDate: task.issueDate.isNotEmpty
          ? task.issueDate
          : state?.issueDate ?? '', // Incluyendo el campo issueDate
      phone: task.phone.isNotEmpty
          ? task.phone
          : state?.phone ?? '', // Incluyendo el campo phone
      service: task.service.isNotEmpty
          ? task.service
          : state?.service ?? '', // Incluyendo el campo service
      documentUrl: task.documentUrl.isNotEmpty
          ? task.documentUrl
          : state?.documentUrl ?? '', // Usando el valor correcto de documentUrl
      workingDays: task.workingDays?.isNotEmpty == true
          ? task.workingDays
          : state?.workingDays ?? [],
      workingHours: task.workingHours?.isNotEmpty == true
          ? task.workingHours
          : state?.workingHours ?? {},
      specialDays: task.specialDays?.isNotEmpty == true
          ? task.specialDays
          : state?.specialDays ?? [],
    );
  }

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

  void resetTask() {
    state = null;
  }
}
