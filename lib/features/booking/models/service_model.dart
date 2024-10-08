import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String image;
  final String category;
  final int price;
  final String title;
  final int star;
  final String agent;

  const ServiceModel({
    required this.image,
    required this.category,
    required this.price,
    required this.title,
    required this.star,
    required this.agent,
  });

  @override
  List<Object?> get props => [
        image,
        category,
        price,
        title,
        star,
        agent,
      ];
}
