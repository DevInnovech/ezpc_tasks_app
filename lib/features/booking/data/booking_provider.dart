import 'package:ezpc_tasks_app/features/booking/data/booking_reposity.dart';
import 'package:ezpc_tasks_app/features/booking/data/firebase_booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/provider_booking_dto.dart';

// Initialize FirebaseBookingService and BookingRepository
final firebaseBookingServiceProvider =
    Provider<FirebaseBookingService>((ref) => FirebaseBookingService());

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final firebaseService = ref.watch(firebaseBookingServiceProvider);
  return BookingRepository(firebaseService);
});

// Provider for fetching all bookings
final bookingListProvider = FutureProvider<ProviderBookingDto>((ref) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return bookingRepository.getProviderAllBookingList();
});

// Provider for fetching booking details
final bookingDetailsProvider =
    FutureProvider.family<BookingDetailsDto, String>((ref, id) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return bookingRepository.getSingleBooking(id);
});
final serviceStateProvider = StateProvider<ServiceState>((ref) {
  return ServiceState.initial; // Initial state: not started
});

// Enum for Service State
enum ServiceState {
  initial, // Before starting
  started,
  inProgress,
  completed,
}

// State provider to track if extra time was requested
final extraTimeRequestedProvider = StateProvider<bool>((ref) {
  return false; // Initially no extra time requested
});

// Provider to store and manage the extra time details (duration, fee, etc.)
final extraTimeDetailsProvider = StateProvider<ExtraTimeDetails>((ref) {
  return ExtraTimeDetails(); // Holds the requested extra time information
});

// Model to hold extra time details
class ExtraTimeDetails {
  String selectedDuration = '';
  String selectedTimeSlot = '';
  String reason = '';
  String status = 'Pending';
  double fee = 0.0;
}
