import 'package:ezpc_tasks_app/features/About%20me/models/AboutMeModel.dart';
import 'package:ezpc_tasks_app/features/About%20me/models/review_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutMeRepository {
  // Método para simular la obtención de datos del perfil del proveedor
  Future<AboutMeModel> getAboutMe() async {
    // Datos falsos para visualizar en el perfil
    return AboutMeModel(
      rating: 4,
      serviceType: 'Car Repair',
      imagen: KImages.pp,
      name: 'Juan Perez',
      description:
          'Proveedor experimentado en servicios de construcción y remodelación.',
      location: 'Ciudad de México, MX',
      contactNumber: '+52 55 1234 5678',
      gallery: [
        KImages.pp,
        KImages.pp,
        KImages.pp,
        KImages.pp,
        KImages.pp,
        KImages.pp,
      ],
      reviews: [
        ReviewModel(
          userName: 'Maria Garcia',
          date: DateTime.now(),
          comment: 'Excelente trabajo y puntualidad.',
          rating: 5,
          imagen: KImages.pp,
        ),
        ReviewModel(
          userName: 'Carlos Ruiz',
          date: DateTime.now(),
          comment: 'Muy profesional y cumplió con las expectativas.',
          rating: 4,
          imagen: KImages.pp,
        ),
      ],
    );
  }
}

// Proveedor para el repositorio de AboutMe
final aboutMeRepositoryProvider = Provider((ref) => AboutMeRepository());
