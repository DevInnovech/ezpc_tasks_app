import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/data/booking_reposity.dart';
import 'package:ezpc_tasks_app/features/booking/data/firebase_booking_service.dart';
import 'package:flutter/material.dart';
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

final bookingDataProvider = StreamProvider.family<Map<String, dynamic>, String>(
    (ref, bookingId) async* {
  try {
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots();
    await for (final snapshot in stream) {
      if (snapshot.exists) {
        yield snapshot.data() as Map<String, dynamic>;
      } else {
        yield {};
      }
    }
  } catch (e) {
    debugPrint("Error fetching booking data: $e");
    yield {};
  }
});

final extraTimeRequestedProvider =
    Provider.family<bool, String>((ref, bookingId) {
  final booking = ref.watch(bookingDataProvider(bookingId)).value;
  return booking?['extraTime'] != null;
});

final extraTimeDetailsProvider =
    Provider.family<ExtraTimeDetails, String>((ref, bookingId) {
  final booking = ref.watch(bookingDataProvider(bookingId)).value;
  if (booking != null && booking['extraTime'] != null) {
    final extraTime = booking['extraTime'] as Map<String, dynamic>;
    return ExtraTimeDetails(
      selectedDuration: extraTime['selectedDuration'] ?? '',
      selectedTimeSlot: extraTime['selectedTimeSlot'] ?? '',
      reason: extraTime['reason'] ?? '',
      status: extraTime['status'] ?? 'Pending',
      fee: (extraTime['fee'] as num?)?.toDouble() ?? 0.0,
    );
  }
  return ExtraTimeDetails();
});

// Model to hold extra time details
class ExtraTimeDetails {
  String selectedDuration;
  String selectedTimeSlot;
  String reason;
  String status;
  double fee;

  ExtraTimeDetails({
    this.selectedDuration = '',
    this.selectedTimeSlot = '',
    this.reason = '',
    this.status = 'Pending',
    this.fee = 0.0,
  });
}

final extraTimeLocalProvider =
    StateNotifierProvider.family<ExtraTimeNotifier, ExtraTimeDetails, String>(
        (ref, bookingId) => ExtraTimeNotifier());

class ExtraTimeNotifier extends StateNotifier<ExtraTimeDetails> {
  ExtraTimeNotifier() : super(ExtraTimeDetails());

  void update(ExtraTimeDetails details) {
    state = details;
  }
}

// Llama a este método al enviar una solicitud de tiempo extra
void optimisticUpdate(
    String bookingId, ExtraTimeDetails details, WidgetRef ref) {
  ref.read(extraTimeLocalProvider(bookingId).notifier).update(details);
}
