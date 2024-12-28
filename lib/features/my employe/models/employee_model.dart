import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String name;
  final String userid;
  final String imageUrl;
  final String date;
  final int tasksCompleted;
  final double earnings;
  final bool isActive;

  const EmployeeModel({
    required this.userid,
    required this.name,
    required this.imageUrl,
    required this.date,
    required this.tasksCompleted,
    required this.earnings,
    required this.isActive,
  });

  // Convertir el modelo en un mapa para almacenarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'name': name,
      'imageUrl': imageUrl,
      'date': date,
      'tasksCompleted': tasksCompleted,
      'earnings': earnings,
      'isActive': isActive,
    };
  }

  // Crear el modelo a partir de un mapa
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      userid: map['userid'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      date: map['date'],
      tasksCompleted: map['tasksCompleted'],
      earnings: map['earnings'],
      isActive: map['isActive'],
    );
  }

  @override
  List<Object?> get props =>
      [userid, name, imageUrl, date, tasksCompleted, earnings, isActive];
}
