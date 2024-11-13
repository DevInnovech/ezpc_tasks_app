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
}
