import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:ezpc_tasks_app/features/services/models/task_model.dart'
    as TaskModel;
import 'package:ezpc_tasks_app/features/services/data/task_repository.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});

class TaskState {
  final List<TaskModel.Task> tasks;
  final TaskModel.Task? currentTask;
  final bool isLoading;
  final String? error;

  TaskState({
    required this.tasks,
    this.currentTask,
    required this.isLoading,
    this.error,
  });

  factory TaskState.initial() {
    return TaskState(tasks: [], isLoading: false, error: null);
  }

  TaskState copyWith({
    List<TaskModel.Task>? tasks,
    TaskModel.Task? currentTask,
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

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  TaskNotifier(this._repository) : super(TaskState.initial()) {
    _loadTasks();
  }

  void initializeNewTask() {
    final emptyTask = TaskModel.Task(
      id: const Uuid().v4(),
      name: '',
      category: '',
      subCategory: '',
      price: 0.0,
      imageUrl: '', // Se inicializa en vacío
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

    state = state.copyWith(currentTask: emptyTask);
  }

  Future<void> _loadTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      List<TaskModel.Task> tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(tasks: [], isLoading: false, error: e.toString());
    }
  }

  Future<void> selectAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        debugPrint('No se seleccionó ninguna imagen.');
        return;
      }

      String imageUrl;
      if (kIsWeb) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        imageUrl = await _uploadImageBytes(imageBytes, pickedFile.name);
      } else {
        final File imageFile = File(pickedFile.path);
        imageUrl = await _uploadImage(imageFile);
      }

      // Verificar que la URL de la imagen no esté vacía antes de actualizar el estado
      if (imageUrl.isNotEmpty) {
        final updatedTask = state.currentTask?.copyWith(imageUrl: imageUrl);
        if (updatedTask != null) {
          state = state.copyWith(currentTask: updatedTask);
        }
        debugPrint('Imagen subida correctamente: $imageUrl');
      } else {
        debugPrint(
            'Error: La URL de la imagen está vacía después de la subida.');
      }
    } catch (e) {
      debugPrint('Error al seleccionar y subir la imagen: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final ref = _storage.ref().child('tasks/$fileName');
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      debugPrint('URL de la imagen subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir la imagen a Firebase Storage: $e');
      return '';
    }
  }

  Future<String> _uploadImageBytes(
      Uint8List imageBytes, String fileName) async {
    try {
      final ref = _storage.ref().child('tasks/$fileName');
      await ref.putData(imageBytes);
      String downloadUrl = await ref.getDownloadURL();
      debugPrint('URL de la imagen subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir la imagen a Firebase Storage: $e');
      return '';
    }
  }

  Future<void> saveTask(TaskModel.Task task) async {
    try {
      final newTask = TaskModel.Task(
        id: task.id.isNotEmpty
            ? task.id
            : const Uuid().v4(), // Validación del ID
        name: task.name,
        category: task.category,
        subCategory: task.subCategory,
        price: task.price,
        imageUrl: task.imageUrl,
        requiresLicense: task.requiresLicense,
        licenseType: task.licenseType,
        licenseNumber: task.licenseNumber,
        licenseExpirationDate: task.licenseExpirationDate,
        workingDays: List<String>.from(task.workingDays),
        workingHours: task.workingHours.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value))),
        specialDays: List<Map<String, String>>.from(task.specialDays),
        documentUrl: task.documentUrl,
        phone: task.phone,
        service: task.service,
        issueDate: task.issueDate,
      );

      await _repository.saveTask(newTask);
      state = state
          .copyWith(tasks: [...state.tasks, newTask], currentTask: newTask);
      debugPrint('Tarea guardada correctamente con la imagen.');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Error al guardar la tarea: $e');
    }
  }

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
    if (state.currentTask == null) return;

    final updatedTask = TaskModel.Task(
      id: state.currentTask!.id,
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
              (key, value) => MapEntry(key, Map<String, String>.from(value))),
      specialDays: specialDays ??
          List<Map<String, String>>.from(state.currentTask!.specialDays),
      documentUrl: documentUrl ?? state.currentTask!.documentUrl,
      phone: phone ?? state.currentTask!.phone,
      service: service ?? state.currentTask!.service,
      issueDate: issueDate ?? state.currentTask!.issueDate,
    );

    state = state.copyWith(currentTask: updatedTask);
  }

  // Validación adicional para asegurar que `imageUrl` no sea nulo o vacío en el widget de la UI
  bool isValidImageUrl() {
    return state.currentTask?.imageUrl != null &&
        state.currentTask!.imageUrl.isNotEmpty;
  }
}
