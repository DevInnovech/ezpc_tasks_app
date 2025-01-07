import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/employee_model.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeCard({super.key, required this.employee});

  Future<String> _fetchUserImage(String userId) async {
    try {
      // Obtener el documento del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Reemplaza con tu colección en Firestore
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Suponiendo que la URL de la imagen está almacenada en el campo 'imageUrl'
        return userDoc.get('profileImageUrl') as String? ?? '';
      } else {
        print("No se encontró el usuario con ID: $userId");
        return ''; // Retorna una URL vacía si no se encuentra el documento
      }
    } catch (e) {
      print("Error al obtener la imagen del usuario: $e");
      return ''; // Retorna una URL vacía en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _fetchUserImage(employee.userid), // Buscar la imagen
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 25.0,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError || (snapshot.data ?? '').isEmpty) {
                  return const ClipOval(
                    child: Image(
                      image: AssetImage(KImages.pp),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  );
                }

                return ClipOval(
                  child: Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Icon(Icons.error); // Icono de fallback
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        employee.date
                            .split(' ')
                            .first, // Truncar al primer espacio
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task: ${employee.tasksCompleted}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color:
                                  employee.isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              "\$${employee.earnings}",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
