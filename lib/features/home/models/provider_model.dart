import 'dart:convert';
import 'package:equatable/equatable.dart';

class TimeSlotModel extends Equatable {
  final String time;
  final bool isAvailable;

  const TimeSlotModel({
    required this.time,
    required this.isAvailable,
  });

  TimeSlotModel copyWith({
    String? time,
    bool? isAvailable,
  }) {
    return TimeSlotModel(
      time: time ?? this.time,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time,
      'isAvailable': isAvailable,
    };
  }

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) {
    return TimeSlotModel(
      time: map['time'] ?? "",
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeSlotModel.fromJson(String source) =>
      TimeSlotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [time, isAvailable];
}

class ProviderModel extends Equatable {
  final int id;
  final String name;
  final String? email; // Opcional
  final String? phone; // Opcional
  final String? image; // Opcional
  final String? createdAt; // Opcional
  final String? userName; // Opcional
  final double rating;
  final int reviews;
  final String? profession; // Opcional
  final List<TimeSlotModel>? timeSlots; // Opcional

  const ProviderModel({
    required this.id,
    required this.name,
    this.email, // Opcional
    this.phone, // Opcional
    this.image, // Opcional
    this.createdAt, // Opcional
    this.userName, // Opcional
    required this.rating,
    required this.reviews,
    this.profession, // Opcional
    this.timeSlots, // Opcional
  });

  ProviderModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    String? createdAt,
    String? userName,
    double? rating,
    int? reviews,
    String? profession,
    List<TimeSlotModel>? timeSlots,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      profession: profession ?? this.profession,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'createdAt': createdAt,
      'userName': userName,
      'rating': rating,
      'reviews': reviews,
      'profession': profession,
      'timeSlots': timeSlots?.map((timeSlot) => timeSlot.toMap()).toList(),
    };
  }

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? "",
      email: map['email'], // Opcional
      phone: map['phone'], // Opcional
      image: map['image'], // Opcional
      createdAt: map['createdAt'], // Opcional
      userName: map['userName'], // Opcional
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews'] ?? 0,
      profession: map['profession'], // Opcional
      timeSlots: map['timeSlots'] != null
          ? List<TimeSlotModel>.from(
              map['timeSlots'].map((x) => TimeSlotModel.fromMap(x)),
            )
          : null, // Opcional
    );
  }

  String toJson() => json.encode(toMap());

  factory ProviderModel.fromJson(String source) =>
      ProviderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      email,
      phone,
      image,
      createdAt,
      userName,
      rating,
      reviews,
      profession,
      timeSlots,
    ];
  }
}
