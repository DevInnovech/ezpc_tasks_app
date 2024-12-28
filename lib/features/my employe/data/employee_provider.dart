import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/my%20employe/models/employee_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final employeeSearchProvider =
    StateProvider<String>((ref) => ''); // Estado para la búsqueda

final filteredEmployeeListProvider =
    FutureProvider.autoDispose<List<EmployeeModel>>((ref) async {
  // Obtener el usuario autenticado
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("Usuario no autenticado");
    throw Exception('User not authenticated');
  }
  print("Usuario autenticado: ${user.uid}");

  // Obtener el documento del proveedor usando el UID del usuario
  final providerDoc = await FirebaseFirestore.instance
      .collection('providers')
      .doc(user.uid)
      .get();

  if (!providerDoc.exists) {
    print("Documento del proveedor no encontrado para UID: ${user.uid}");
    throw Exception('Provider document not found');
  }

  // Obtener la lista de empleados del campo 'Employees'
  final employeesData = providerDoc.data()?['Employees'] as List<dynamic>?;
  print('Datos de empleados recuperados: $employeesData');

  if (employeesData == null || employeesData.isEmpty) {
    print("No hay empleados en el campo Employees");
    return []; // No hay empleados en este proveedor
  }

  // Convertir la lista de datos en modelos de EmployeeModel
  final employees = employeesData
      .map((employeeData) {
        try {
          final model =
              EmployeeModel.fromMap(employeeData as Map<String, dynamic>);
          print("Empleado convertido: $model");
          return model;
        } catch (e) {
          print('Error al convertir empleado: $e');
          return null;
        }
      })
      .whereType<EmployeeModel>()
      .toList();

  print('Modelos de empleados después de la conversión: $employees');

  // Obtener el término de búsqueda
  final query = ref.watch(employeeSearchProvider);
  print('Término de búsqueda: $query');

  // Filtrar empleados basados en el término de búsqueda
  final filteredEmployees = employees.where((employee) {
    return employee.name.toLowerCase().contains(query.toLowerCase());
  }).toList();

  print('Empleados filtrados: $filteredEmployees');

  return filteredEmployees;
});
