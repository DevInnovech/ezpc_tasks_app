import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userName;
  final String imagen;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.userName,
    required this.imagen,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // Método fromMap
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      userName: map['userName'] ?? '',
      imagen: map['imagen'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(), // Convierte a double
      comment: map['comment'] ?? '',
      date:
          (map['date'] as Timestamp).toDate(), // Convierte Timestamp a DateTime
    );
  }

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'imagen': imagen,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(), // Convierte DateTime a ISO8601
    };
  }
}
