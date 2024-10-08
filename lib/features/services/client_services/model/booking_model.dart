import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final String selectedServiceId; // Add this field
  final String selectedTimeSlot;
  final DateTime? selectedDate;
  final bool isForAnotherPerson;

  const BookingModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.selectedServiceId = '', // Initialize this field
    this.selectedTimeSlot = '',
    this.selectedDate,
    this.isForAnotherPerson = false,
  });

  BookingModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    String? selectedServiceId, // Add this to copyWith method
    String? selectedTimeSlot,
    DateTime? selectedDate,
    bool? isForAnotherPerson,
  }) {
    return BookingModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      selectedServiceId:
          selectedServiceId ?? this.selectedServiceId, // Add this line
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      selectedDate: selectedDate ?? this.selectedDate,
      isForAnotherPerson: isForAnotherPerson ?? this.isForAnotherPerson,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        address,
        notes,
        selectedServiceId, // Include this in props
        selectedTimeSlot,
        selectedDate,
        isForAnotherPerson,
      ];
}
