import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String name;
  final String imageUrl;
  final String date;
  final int tasksCompleted;
  final double earnings;
  final bool isActive;

  const EmployeeModel({
    required this.name,
    required this.imageUrl,
    required this.date,
    required this.tasksCompleted,
    required this.earnings,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [name, imageUrl, date, tasksCompleted, earnings, isActive];
}
