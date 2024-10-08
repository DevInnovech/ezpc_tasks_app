import 'package:ezpc_tasks_app/features/services/client_services/model/booking_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingNotifier extends StateNotifier<BookingModel> {
  BookingNotifier() : super(const BookingModel());

  // Store the selected service and date
  void setServiceAndDate(String serviceId, DateTime selectedDate) {
    state = state.copyWith(
      selectedServiceId: serviceId, // Use the selected service ID
      selectedDate: selectedDate,
    );
  }

  // Store the selected time slot
  void setTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  // Store if booking is for another person
  void setForAnotherPerson(bool value) {
    state = state.copyWith(isForAnotherPerson: value);
  }

  // Update client details (auto-filled or entered manually)
  void updateClientDetails({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
    );
  }

  // Update form values for custom entries (for another person)
  void updateCustomName(String name) {
    state = state.copyWith(name: name);
  }

  void updateCustomEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateCustomPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateCustomAddress(String address) {
    state = state.copyWith(address: address);
  }

  // Update notes field
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  // Proceed with the client details (auto-filled)
  void proceedWithClientDetails() {
    // Logic to proceed with booking using auto-filled client details
  }

  // Proceed with custom details (for another person)
  void proceedWithCustomDetails() {
    // Logic to proceed with booking using custom details for another person
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingModel>((ref) {
  return BookingNotifier();
});

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentModel>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<PaymentModel> {
  PaymentNotifier() : super(PaymentModel());

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedMethod: method);
  }

  void processPayment() {
    // Handle payment processing logic
  }
}

class PaymentModel {
  final String selectedMethod;

  PaymentModel({this.selectedMethod = ''});

  PaymentModel copyWith({String? selectedMethod}) {
    return PaymentModel(
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }
}
