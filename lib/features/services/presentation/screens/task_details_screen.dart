import 'package:ezpc_tasks_app/features/auth/models/account_type.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/edit_service_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<Map<String, dynamic>> assignedEmployees = [];

  @override
  void initState() {
    super.initState();
    currentTask = widget.task; // Inicializamos con el `task` inicial
    if (ref.read(accountTypeProvider) == AccountType.corporateProvider) {
      _fetchAssignedEmployees(); // Cargar los empleados asignados
    }
    _fetchCollaborators();
  }

  List<Map<String, dynamic>> collaborators = [];

  Future<void> _fetchCollaborators() async {
    // Ensure collaborators exist and are in the expected format
    if (currentTask.collaborators == null ||
        currentTask.collaborators!.isEmpty) {
      setState(() {
        collaborators = [];
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> fetchedCollaborators = [];

      // Ensure currentTask.collaborators is an iterable of strings
      for (var collaborator in currentTask.collaborators!) {
        // Assuming collaborators is a list of strings or contains an 'id' field
        final String collaboratorId = collaborator['id'].toString();

        final collaboratorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(collaboratorId)
            .get();

        if (collaboratorDoc.exists) {
          final data = collaboratorDoc.data();
          fetchedCollaborators.add({
            'id': collaboratorId,
            'name': data?['name'] ?? 'Unknown',
            'photoUrl': data?['profileImageUrl'] ?? '',
            'active': collaborator["status"].toString() == "Accepted",
          });
        }
      }

      setState(() {
        collaborators = fetchedCollaborators;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching collaborators: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching collaborators: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleTaskStatus() async {
    try {
      setState(() {
        isLoading = true;
      });

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('taskId', isEqualTo: currentTask.taskId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Task not found in Firestore');
      }

      final taskDoc = querySnapshot.docs.first;

      final newStatus = currentTask.status == 1 ? 0 : 1;

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskDoc.id)
          .update({'status': newStatus});

      setState(() {
        currentTask = Task.fromMap({
          ...taskDoc.data(),
          'taskId': currentTask.taskId,
          'status': newStatus,
        });
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 1
              ? 'Task activated successfully'
              : 'Task deactivated successfully'),
          backgroundColor: newStatus == 1 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
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

  Future<void> _toggleAssignmentStatus() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('taskId', isEqualTo: currentTask.taskId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Task not found in Firestore');
      }

      final taskDoc = querySnapshot.docs.first;

      // Obtener el estado actual del usuario asignado
      final currentAssignments =
          (taskDoc.data()['assignments'] as Map<String, dynamic>? ?? {});
      final currentStatus = currentAssignments[userId] ?? false;

      // Alternar el estado (true -> false o false -> true)
      final newStatus = !currentStatus;

      // Actualizar el campo `assignments` en Firestore
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskDoc.id)
          .update({
        'assignments.$userId': newStatus,
      });

      setState(() {
        currentTask = Task.fromMap({
          ...taskDoc.data(),
          'taskId': currentTask.taskId,
          'assignments': {
            ...(currentTask.assignments ?? {}),
            userId: newStatus,
          },
        });
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Assignment activated successfully'
                : 'Assignment deactivated successfully',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error toggling assignment status'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error toggling assignment status: $e');
    }
  }

  Future<void> _unassignTask() async {
    print("Unassign Task triggered");
    try {
      setState(() {
        isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Verificar si existen bookings conflictivos
      final conflictingBookingsExists = await FirebaseFirestore.instance
          .collection('bookings')
          .where('taskId', isEqualTo: currentTask.taskId)
          .where('status',
              whereNotIn: ['completed', 'canceled']) // Estados conflictivos
          .limit(1) // Solo necesitamos saber si existe al menos uno
          .get()
          .then((snapshot) =>
              snapshot.docs.isEmpty); // Retorna `true` si hay documentos

      if (conflictingBookingsExists) {
        throw Exception(
            'Cannot unassign task: There are bookings that are not completed or canceled');
      }

      // Buscar la tarea en Firestore
      final taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .where('taskId', isEqualTo: currentTask.taskId)
          .limit(1)
          .get();

      if (taskDoc.docs.isEmpty) {
        throw Exception('Task not found in Firestore');
      }

      final taskData = taskDoc.docs.first;

      // Eliminar al usuario del campo `assignments` en Firestore
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskData.id)
          .update({
        'assignments.$userId': FieldValue.delete(),
      });

      // Actualizar el estado local de la tarea
      setState(() {
        currentTask = Task.fromMap({
          ...taskData.data(),
          'taskId': currentTask.taskId,
          'assignments': {
            ...(currentTask.assignments ?? {})..remove(userId),
          },
        });
        isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task unassigned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Mostrar mensaje de error
      final errorMessage =
          e.toString().contains('bookings that are not completed or canceled')
              ? 'Cannot unassign task: Active bookings exist'
              : 'Error unassigning task';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Error unassigning task: $e');
    }
  }

  Future<void> _assignTask() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('taskId', isEqualTo: currentTask.taskId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Task not found in Firestore');
      }

      final taskDoc = querySnapshot.docs.first;

      // Actualizar el campo `assignments` con el ID del empleado
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskDoc.id)
          .update({
        'assignments.$userId': true,
      });

      setState(() {
        currentTask = Task.fromMap({
          ...taskDoc.data(),
          'taskId': currentTask.taskId,
          'assignments': {
            ...(currentTask.assignments ?? {}),
            userId: true,
          },
        });
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error assigning task'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error assigning task: $e');
    }
  }

  Future<void> _fetchAssignedEmployees() async {
    if (currentTask.assignments == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> employees = [];
      for (String userId in currentTask.assignments!.keys) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          employees.add({
            'id': userId,
            'name': userDoc.data()?['name'] ?? 'Unknown',
            'photoUrl': userDoc.data()?['profileImageUrl'] ?? '',
            'active': currentTask.assignments![userId],
          });
        }
      }

      setState(() {
        assignedEmployees = employees;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching assigned employees: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildAssignedEmployeesWidget() {
    if (assignedEmployees.isEmpty) {
      return const Center(
        child: Text(
          'No employees assigned.',
          style: TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Employees',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF404C8C),
          ),
        ),
        const SizedBox(height: 10.0),
        ...assignedEmployees.map((employee) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: employee['photoUrl'].isNotEmpty
                    ? NetworkImage(employee['photoUrl'])
                    : null,
                backgroundColor: Colors.grey.shade300,
                child: employee['photoUrl'].isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                employee['name'],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                employee['active'] == 'true' ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 14.0,
                  color:
                      employee['active'] == 'true' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCollaboratorsWidget() {
    if (collaborators.isEmpty) {
      return const Center(
        child: Text(
          'No collaborators available.',
          style: TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collaborators',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF404C8C),
          ),
        ),
        const SizedBox(height: 10.0),
        ...collaborators.map((collaborator) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: collaborator['photoUrl'].isNotEmpty
                    ? NetworkImage(collaborator['photoUrl'])
                    : null,
                backgroundColor: Colors.grey.shade300,
                child: collaborator['photoUrl'].isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                collaborator['name'],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                collaborator['active'] == true ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 14.0,
                  color: collaborator['active'] == true
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountType = ref.watch(accountTypeProvider);

    final userId = FirebaseAuth.instance.currentUser?.uid;

    final isAssigned = currentTask.assignments != null &&
        currentTask.assignments!.containsKey(userId);

    final isActive = currentTask.assignments![userId] == 'true';

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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            currentTask.imageUrl.isNotEmpty
                                ? currentTask.imageUrl
                                : 'https://via.placeholder.com/200',
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
                        if (accountType == AccountType.employeeProvider &&
                            isAssigned)
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.8)
                                  : Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10.0),
                              /* border: Border.all(
                                color: isActive ? Colors.green : Colors.orange,
                                width: 1.5,
                              ),*/
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTask.category.isNotEmpty
                              ? currentTask.category
                              : 'No SubCategory',
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
                              '\$${currentTask.price.toStringAsFixed(2)}',
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
                                  currentTask.averageRating.isNotEmpty
                                      ? currentTask.averageRating
                                      : '0.0',
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
                    _buildSectionTitle('Description'),
                    Text(
                      currentTask.details.isNotEmpty
                          ? currentTask.details
                          : 'No description available',
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (currentTask.selectedTasks.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Selected Tasks'),
                          ...currentTask.selectedTasks.entries.map((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      )
                    else
                      const Text(
                        'No selected tasks available.',
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                      ),
                    const SizedBox(height: 16.0),
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
                    _buildSectionTitle('Working Hours'),
                    if (currentTask.workingHours.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF404C8C)),
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              currentTask.workingHours.entries.map((entry) {
                            Map<String, String> hours = {};
                            hours = (entry.value as Map).map(
                              (key, value) =>
                                  MapEntry(key.toString(), value.toString()),
                            );

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16.0, color: Color(0xFF404C8C)),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    '${entry.key}: ${hours['start'] ?? ''} - ${hours['end'] ?? ''}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      const Text('No working hours available.'),
                    const SizedBox(height: 20.0),
                    if (accountType == AccountType.corporateProvider)
                      _buildAssignedEmployeesWidget(),
                    if (collaborators.isNotEmpty) _buildCollaboratorsWidget(),
                  ],
                ),
              ),
            ),
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
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : accountType == AccountType.employeeProvider
                        ? isAssigned
                            ? _toggleAssignmentStatus
                            : null
                        : _toggleTaskStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accountType == AccountType.employeeProvider
                      ? isActive
                          ? Colors.red
                          : Colors.green
                      : currentTask.status == 1
                          ? Colors.red
                          : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  accountType == AccountType.employeeProvider
                      ? isActive
                          ? 'Deactivate'
                          : 'Activate'
                      : currentTask.status == 1
                          ? 'Deactivate'
                          : 'Activate',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: accountType == AccountType.employeeProvider
                    ? isAssigned
                        ? _unassignTask
                        : _assignTask
                    : () {
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
                child: Text(
                  accountType == AccountType.employeeProvider
                      ? isAssigned
                          ? 'Unassign'
                          : 'Assign Task'
                      : 'Edit Task',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
