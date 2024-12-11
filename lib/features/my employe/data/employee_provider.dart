import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/employee_repository.dart';
import '../models/employee_model.dart';

// Provider to fetch the list of employees from the repository
final employeeListProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployees();
});

// State provider for managing the search query
final employeeSearchProvider = StateProvider<String>((ref) => '');

// Filtered employee list provider that watches the search query and employee list
final filteredEmployeeListProvider = Provider<List<EmployeeModel>>((ref) {
  final searchQuery = ref.watch(employeeSearchProvider).toLowerCase();
  final employeeList = ref.watch(employeeListProvider).maybeWhen(
        data: (employees) => employees,
        orElse: () => <EmployeeModel>[], // Explicitly specify the type here
      );

  if (searchQuery.isEmpty) {
    return employeeList;
  }

  // Filtering employees based on the search query
  return employeeList.where((employee) {
    return employee.name.toLowerCase().contains(searchQuery) ||
        employee.tasksCompleted.toString().contains(searchQuery);
  }).toList();
});
