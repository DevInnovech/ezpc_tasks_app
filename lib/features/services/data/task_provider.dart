import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> initializeNewTask(String providerId) async {
    try {
      // Obtener los datos del proveedor desde Firebase
      final providerDoc = await FirebaseFirestore.instance
          .collection(
              'providers') // Asegúrate de usar el nombre correcto de la colección
          .doc(providerId)
          .get();

      if (!providerDoc.exists) {
        throw Exception('Proveedor no encontrado.');
      }

      final providerData = providerDoc.data()!;
      final firstName = providerData['name'] ?? '';
      final lastName = providerData['lastName'] ?? '';
      final userID = providerData['userId'] ?? providerId;

      // Crear una tarea inicializada con los datos del proveedor
      final emptyTask = TaskModel.Task(
        id: const Uuid().v4(),
        taskId: '',
        taskName: '',
        firstName: firstName,
        lastName: lastName,
        slug: '',
        categoryId: '',
        category: '',
        subCategory: '',
        subCategoryprice: 0.0,
        price: 0.0,
        type: '',
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
        additionalOption: '',
        makeFeatured: 0,
        isBanned: 0,
        status: 1,
        createdAt: DateTime.now().toIso8601String(),
        approveByAdmin: 0,
        averageRating: '0.0',
        totalReview: 0,
        totalOrder: 0,
        providerId: userID,
        provider: null,
        details: '',
        duration: '',
        description: '',
        clientName: '',
        clientLastName: '',
        questions: {},
        selectedTasks: {},
        assignments: {},
      );

      state = state.copyWith(currentTask: emptyTask);
      debugPrint('Tarea inicializada correctamente.');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Error al inicializar la tarea: $e');
    }
  }

/*
  /// Cargar preguntas de Firebase basadas en los servicios seleccionados
  Future<void> loadQuestionsForSelectedServices() async {
    final currentTask = state.currentTask;
    if (currentTask == null || currentTask.service.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(currentTask.categoryId)
          .get();

      if (!categoryDoc.exists) return;

      final List<dynamic> services = categoryDoc.data()?['services'] ?? [];
      final List<String> selectedServices =
          currentTask.service.split(',').map((s) => s.trim()).toList();

      Map<String, List<String>> questionsMap = {};

      for (String serviceName in selectedServices) {
        final service = services.firstWhere(
          (s) => s['name'] == serviceName,
          orElse: () => null,
        );

        if (service != null && service['questions'] != null) {
          final List<dynamic> questions = service['questions'];
          questionsMap[serviceName] =
              questions.map((q) => q.toString()).toList();
        }
      }

      final updatedTask = currentTask.copyWith(
        questions: jsonEncode(questionsMap),
      );

      state = state.copyWith(
        currentTask: updatedTask,
        isLoading: false,
      );

      debugPrint('Preguntas cargadas exitosamente.');
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Error al cargar preguntas: $e');
      debugPrint('Error al cargar preguntas: $e');
    }
  }
*/
  Future<void> _loadTasks() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        throw Exception('No hay usuario logueado.');
      }

      state = state.copyWith(isLoading: true, error: null);

      // Obtener el tipo de cuenta directamente desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('No se encontró el documento del usuario.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final accountType = userData['accountType'] ?? '';

      String providerUserId =
          userId; // Por defecto usamos el ID del usuario actual

      if (accountType == 'Employee Provider') {
        print("aqui");
        // El usuario es de tipo empleado, buscar su proveedor corporativo
        final employeeDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(userId)
            .get();

        if (!employeeDoc.exists) {
          throw Exception(
              'El documento del empleado no existe en la colección providers.');
        }

        final employeeData = employeeDoc.data() as Map<String, dynamic>;
        final myCompanyId = employeeData['Company'];

        if (myCompanyId == null || myCompanyId.isEmpty) {
          throw Exception(
              'El campo "Company" no está definido para este empleado.');
        }

        // Buscar el proveedor corporativo con el companyId igual a myCompanyId
        final companyQuery = await FirebaseFirestore.instance
            .collection('providers')
            .where('companyID', isEqualTo: myCompanyId)
            .limit(1)
            .get();

        if (companyQuery.docs.isEmpty) {
          throw Exception(
              'No se encontró ningún proveedor corporativo con el companyID: $myCompanyId.');
        }

        final companyData = companyQuery.docs.first.id;
        providerUserId = companyData;

        if (providerUserId.isEmpty) {
          throw Exception(
              'El proveedor corporativo no tiene definido un "userId".');
        }
      }

      // Buscar las tareas en Firestore para el usuario o proveedor corporativo
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where("providerId", isEqualTo: providerUserId)
          .get();

      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return TaskModel.Task.fromMap(data);
      }).toList();

      state = state.copyWith(tasks: tasks, isLoading: false);
      debugPrint('Tareas cargadas correctamente.');
    } catch (e) {
      state = state.copyWith(tasks: [], isLoading: false, error: e.toString());
      debugPrint('Error al cargar las tareas: $e');
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

  Future<void> uploadImageFromLocalUrl(
      String localUrl, TaskModel.Task task) async {
    try {
      if (localUrl.isEmpty) {
        debugPrint('No se proporcionó una URL de imagen válida.');
        return;
      }

      final File imageFile = File(localUrl);

      if (!imageFile.existsSync()) {
        debugPrint('El archivo especificado no existe.');
        return;
      }

      String imageUrl = await _uploadImage(imageFile);

      if (imageUrl.isNotEmpty) {
        final updatedTask = task.copyWith(imageUrl: imageUrl);
        state = state.copyWith(currentTask: updatedTask);
        await saveTask(updatedTask);
        debugPrint('Imagen subida correctamente: $imageUrl');
      } else {
        debugPrint(
            'Error: La URL de la imagen está vacía después de la subida.');
      }
    } catch (e) {
      debugPrint('Error al subir la imagen desde la URL local: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final ref = _storage.ref().child('tasks/$fileName');
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
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
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir la imagen a Firebase Storage: $e');
      return '';
    }
  }

  Future<void> saveTask(TaskModel.Task task) async {
    try {
      // Automatically generate a taskId if not provided
      final taskId = task.taskId.isNotEmpty ? task.taskId : const Uuid().v4();

      // Determine the taskName based on subCategory and category
      final taskName =
          (task.subCategory.isNotEmpty) ? task.subCategory : task.category;

      // Create a new instance of the task with updated values
      final newTask = TaskModel.Task(
        id: task.id.isNotEmpty ? task.id : const Uuid().v4(),
        taskId: taskId, // Assign the generated or existing taskId
        taskName: taskName, // Assign taskName based on conditional logic
        firstName: task.firstName,
        lastName: task.lastName,
        slug: task.slug,
        categoryId: task.categoryId,
        category: task.category,
        subCategory: task.subCategory,
        price: task.price,
        subCategoryprice: task.subCategoryprice,
        type: task.type,
        imageUrl: task.imageUrl,
        requiresLicense: task.requiresLicense,
        licenseType: task.licenseType,
        licenseNumber: task.licenseNumber,
        licenseExpirationDate: task.licenseExpirationDate,
        workingDays: List<String>.from(task.workingDays),
        workingHours: task.workingHours.map(
          (key, value) => MapEntry(
            key,
            Map<String, String>.from(value),
          ),
        ),
        specialDays: List<Map<String, String>>.from(task.specialDays),
        documentUrl: task.documentUrl,
        phone: task.phone,
        service: task.service,
        issueDate: task.issueDate,
        additionalOption: task.additionalOption,
        makeFeatured: task.makeFeatured,
        isBanned: task.isBanned,
        status: task.status,
        createdAt: task.createdAt,
        approveByAdmin: task.approveByAdmin,
        averageRating: task.averageRating,
        totalReview: task.totalReview,
        totalOrder: task.totalOrder,
        providerId: task.providerId,
        provider: task.provider,
        details: task.details,
        questionResponses: task.questionResponses,
        duration: task.duration,
        description: task.description,
        clientName: task.clientName,
        clientLastName: task.clientLastName,
        questions: task.questions, // Asegurarse de guardar preguntas
        selectedTasks: task.selectedTasks,
        assignments: {}, // Guardar tareas seleccionadas
      );

      // Save the task in the repository
      await _repository.saveTask(newTask);

      // Update the state with the new or updated task
      final existingTasks = state.tasks.where((t) => t.id != task.id).toList();
      state = state.copyWith(
        tasks: [...existingTasks, newTask],
        currentTask: newTask,
      );

      debugPrint('Task successfully saved with taskId: $taskId');
    } catch (e) {
      // Capture errors and update the state with the error message
      state = state.copyWith(error: e.toString());
      debugPrint('Error saving task: $e');
    }
  }

  void updateTask({
    String? taskName,
    String? taskId,
    String? firstName,
    String? lastName,
    String? slug,
    String? categoryId,
    String? category,
    String? subCategory,
    double? price,
    double? subCategoryprice,
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
    String? additionalOption,
    int? makeFeatured,
    int? isBanned,
    int? status,
    String? createdAt,
    int? approveByAdmin,
    String? averageRating,
    int? totalReview,
    int? totalOrder,
    String? providerId,
    dynamic provider,
    String? details,
    Map<String, String>? questionResponses,
    String? duration,
    String? description,
    String? clientName,
    String? clientLastName,
    Map<String, String>? questions, // Agregado para actualizar preguntas
    Map<String, double>?
        selectedTasks, // Agregado para actualizar tareas seleccionadas
  }) {
    if (state.currentTask == null) return;

    final updatedTask = state.currentTask!.copyWith(
      taskName: taskName,
      firstName: firstName,
      lastName: lastName,
      slug: slug,
      categoryId: categoryId,
      category: category,
      subCategory: subCategory,
      price: price,
      subCategoryprice: subCategoryprice,
      imageUrl: imageUrl,
      requiresLicense: requiresLicense,
      licenseType: licenseType,
      licenseNumber: licenseNumber,
      licenseExpirationDate: licenseExpirationDate,
      workingDays: workingDays ?? state.currentTask!.workingDays,
      workingHours: workingHours ?? state.currentTask!.workingHours,
      specialDays: specialDays ?? state.currentTask!.specialDays,
      documentUrl: documentUrl,
      phone: phone,
      service: service,
      issueDate: issueDate,
      additionalOption: additionalOption,
      makeFeatured: makeFeatured,
      isBanned: isBanned,
      status: status,
      createdAt: createdAt,
      approveByAdmin: approveByAdmin,
      averageRating: averageRating,
      totalReview: totalReview,
      totalOrder: totalOrder,
      providerId: providerId,
      provider: provider,
      details: details,
      questionResponses:
          questionResponses ?? state.currentTask!.questionResponses,
      questions:
          questions ?? state.currentTask!.questions, // Convertir a String
      selectedTasks: selectedTasks ?? state.currentTask!.selectedTasks,
    );

    state = state.copyWith(currentTask: updatedTask);
    debugPrint('Task updated: ${updatedTask.selectedTasks}');
  }

  Future<void> deleteTask(TaskModel.Task task) async {
    try {
      await _repository.deleteTask(task.id);
      final updatedTasks = state.tasks.where((t) => t.id != task.id).toList();
      state = state.copyWith(tasks: updatedTasks, currentTask: null);
      debugPrint('Tarea eliminada correctamente: ${task.id}');
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar la tarea: $e');
      debugPrint('Error al eliminar la tarea: $e');
    }
  }
}
