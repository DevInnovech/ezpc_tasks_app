import 'package:ezpc_tasks_app/features/About%20me/models/review_model.dart';

class AboutMeModel {
  final String name;
  final String description;
  final String location;
  final String contactNumber;
  final String imagen; // Imagen de perfil del proveedor
  final double rating;
  final String serviceType;
  final List<String> gallery; // Lista de imágenes para la galería
  final List<ReviewModel> reviews; // Lista de reviews de clientes

  AboutMeModel({
    required this.name,
    required this.imagen,
    required this.description,
    required this.location,
    required this.contactNumber,
    required this.rating,
    required this.serviceType,
    required this.gallery,
    required this.reviews,
  });

  AboutMeModel copyWith({
    String? name,
    String? imagen,
    String? description,
    String? location,
    String? contactNumber,
    double? rating,
    String? serviceType,
    List<String>? gallery,
    List<ReviewModel>? reviews,
  }) {
    return AboutMeModel(
      name: name ?? this.name,
      imagen: imagen ?? this.imagen,
      description: description ?? this.description,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      rating: rating ?? this.rating,
      serviceType: serviceType ?? this.serviceType,
      gallery: gallery ?? this.gallery,
      reviews: reviews ?? this.reviews,
    );
  }

  // Método fromMap
  factory AboutMeModel.fromMap(Map<String, dynamic> map) {
    return AboutMeModel(
      name: map['name'] ?? '', // Asegura que no sea null
      imagen: map['imagen'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(), // Convierte a double
      serviceType: map['serviceType'] ?? '',
      gallery: List<String>.from(
          map['gallery'] ?? []), // Convierte explícitamente a List<String>
      reviews: (map['reviews'] as List<dynamic>? ?? [])
          .map((review) => ReviewModel.fromMap(review as Map<String, dynamic>))
          .toList(), // Convierte cada elemento a ReviewModel
    );
  }

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagen': imagen,
      'description': description,
      'location': location,
      'contactNumber': contactNumber,
      'rating': rating,
      'serviceType': serviceType,
      'gallery': gallery,
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }
}
