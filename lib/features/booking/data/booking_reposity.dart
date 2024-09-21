import 'package:ezpc_tasks_app/features/booking/data/firebase_booking_service.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/provider_booking_dto.dart';

class BookingRepository {
  final FirebaseBookingService _firebaseService;

  BookingRepository(this._firebaseService);

  Future<ProviderBookingDto> getProviderAllBookingList() {
    return _firebaseService.getProviderAllBookingList();
  }

  Future<BookingDetailsDto> getSingleBooking(String id) {
    return _firebaseService.getSingleBooking(id);
  }

  Future<void> acceptBooking(String id) {
    return _firebaseService.acceptBooking(id);
  }

  Future<void> declineBooking(String id) {
    return _firebaseService.declineBooking(id);
  }
}
