import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_model.dart';

class EmployeeRepository {
  // This is a mock function to simulate fetching employees.
  // In a real app, this would interact with a database or API.
  Future<List<EmployeeModel>> getEmployees() async {
    return [
      const EmployeeModel(
          name: 'Jose Florez',
          tasksCompleted: 10,
          earnings: 5.0,
          date: '06/02/2024',
          isActive: true,
          imageUrl: KImages.pp),
      const EmployeeModel(
          imageUrl: KImages.pp,
          name: 'Tiffany Plures',
          tasksCompleted: 8,
          earnings: 5.0,
          date: '06/02/2024',
          isActive: true),
      const EmployeeModel(
          imageUrl: KImages.pp,
          name: 'Mary Torrez',
          tasksCompleted: 5,
          earnings: 5.0,
          date: '06/02/2024',
          isActive: false),
      // Add more mock data as needed
    ];
  }
}

// Provider for EmployeeRepository
final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());
