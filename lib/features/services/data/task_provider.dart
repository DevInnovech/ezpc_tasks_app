import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:uuid/uuid.dart';
import 'package:ezpc_tasks_app/features/services/data/task_repository.dart';
import 'package:flutter/foundation.dart';

// Proveedor del TaskNotifier
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});

// Definición de TaskState que agrupa la lista de tareas y el estado de carga
class TaskState {
  final List<Task> tasks;
  final Task? currentTask;
  final bool isLoading;
  final String? error;

  TaskState({
    required this.tasks,
    this.currentTask,
    required this.isLoading,
    this.error,
  });

  // Estado inicial vacío
  factory TaskState.initial() {
    return TaskState(tasks: [], isLoading: false, error: null);
  }

  // Copia del estado actual con nuevos valores
  TaskState copyWith({
    List<Task>? tasks,
    Task? currentTask,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      currentTask: currentTask ?? this.currentTask,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Definición de TaskNotifier que maneja el estado de TaskState
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(TaskState.initial()) {
    _loadTasks();
  }

  // Método para inicializar una nueva tarea vacía con un ID único
  void initializeNewTask() {
    final emptyTask = Task(
      id: const Uuid().v4(),
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
      documentUrl: '',
      phone: '',
      service: '',
      issueDate: DateTime.now().toIso8601String(),
    );

    // Establecer `currentTask` como una nueva instancia vacía en el estado
    state = state.copyWith(currentTask: emptyTask);
  }

  // Método para cargar las tareas desde la base de datos y actualizar el estado
  Future<void> _loadTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print("Cargando tareas desde la base de datos...");

      List<Task> tasks = await _repository.getTasks();

      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(tasks: [], isLoading: false, error: e.toString());
    }
  }

  // Método para guardar una nueva tarea en Firebase
  Future<void> saveTask(Task task) async {
    try {
      // Crear manualmente una nueva instancia de Task con valores específicos
      final newTask = Task(
        id: const Uuid()
            .v4(), // Generar un nuevo id para asegurar que no se sobrescriba nada
        name: task.name,
        category: task.category,
        subCategory: task.subCategory,
        price: task.price,
        imageUrl: task.imageUrl,
        requiresLicense: task.requiresLicense,
        licenseType: task.licenseType,
        licenseNumber: task.licenseNumber,
        licenseExpirationDate: task.licenseExpirationDate,
        workingDays: List<String>.from(
            task.workingDays), // Crear una nueva lista independiente
        workingHours: task.workingHours.map(
          (key, value) => MapEntry(key, Map<String, String>.from(value)),
        ), // Crear un nuevo mapa independiente
        specialDays: List<Map<String, String>>.from(
            task.specialDays), // Nueva lista independiente
        documentUrl: task.documentUrl,
        phone: task.phone,
        service: task.service,
        issueDate: task.issueDate,
      );

      // Guardar la nueva tarea en Firebase
      await _repository.saveTask(newTask);

      // Agregar la nueva tarea al estado, sin modificar otras tareas existentes
      state = state.copyWith(
        tasks: [...state.tasks, newTask],
        currentTask: newTask,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Método para actualizar la `currentTask` en la pantalla de creación/edición
  void updateTask({
    String? name,
    String? category,
    String? subCategory,
    double? price,
    String? imageUrl,
    bool? requiresLicense,
    String? licenseType,
    String? licenseNumber,
    String? licenseExpirationDate,
    List<String>? workingDays,
    Map<String, Map<String, String>>? workingHours,
    List<Map<String, String>>? specialDays,
    String? documentUrl,
    String? phone,
    String? service,
    String? issueDate,
  }) {
    // Asegurarse de que `currentTask` existe antes de actualizar
    if (state.currentTask == null) return;

    // Crear una nueva instancia de `Task` con los valores actualizados
    final updatedTask = Task(
      id: state.currentTask!.id, // Mantener el mismo `id` durante la edición
      name: name ?? state.currentTask!.name,
      category: category ?? state.currentTask!.category,
      subCategory: subCategory ?? state.currentTask!.subCategory,
      price: price ?? state.currentTask!.price,
      imageUrl: imageUrl ?? state.currentTask!.imageUrl,
      requiresLicense: requiresLicense ?? state.currentTask!.requiresLicense,
      licenseType: licenseType ?? state.currentTask!.licenseType,
      licenseNumber: licenseNumber ?? state.currentTask!.licenseNumber,
      licenseExpirationDate:
          licenseExpirationDate ?? state.currentTask!.licenseExpirationDate,
      workingDays:
          workingDays ?? List<String>.from(state.currentTask!.workingDays),
      workingHours: workingHours ??
          state.currentTask!.workingHours.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
          ),
      specialDays: specialDays ??
          List<Map<String, String>>.from(state.currentTask!.specialDays),
      documentUrl: documentUrl ?? state.currentTask!.documentUrl,
      phone: phone ?? state.currentTask!.phone,
      service: service ?? state.currentTask!.service,
      issueDate: issueDate ?? state.currentTask!.issueDate,
    );

    // Actualizar la `currentTask` en el estado con los nuevos valores
    state = state.copyWith(currentTask: updatedTask);
  }

  // Método para restablecer la tarea actual
  void resetTask() {
    state = TaskState.initial();
  }
}
