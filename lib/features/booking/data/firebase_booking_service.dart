import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_data_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/client_info_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/provider_booking_dto.dart';
import 'package:ezpc_tasks_app/features/home/models/currency_icon_model.dart';
import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart'; // Assuming you have a model for currency icon

class FirebaseBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all bookings from Firestore, or provide mock data if none found
  Future<ProviderBookingDto> getProviderAllBookingList() async {
    try {
      //prueba data falsa
      return _getMockBookingData();
      //data real
      /*
      final querySnapshot = await _firestore.collection('bookings').get();

      if (querySnapshot.docs.isEmpty) {
        // Provide mock data if no bookings found
        return _getMockBookingData();
      }

      final bookings = querySnapshot.docs
          .map((doc) =>
              BookingDataDto.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return ProviderBookingDto(
        title: 'Provider Bookings',
        orders: bookings,
        currencyIconModel: CurrencyIconModel(icon: 'default_icon'),
        declienedBooking:
            bookings.where((b) => b.orderStatus == 'declined').length,
        totalAwaiting:
            bookings.where((b) => b.orderStatus == 'awaiting').length,
        activeBooking: bookings.where((b) => b.orderStatus == 'active').length,
        completeBooking:
            bookings.where((b) => b.orderStatus == 'complete').length,
      );
    */
    } catch (e) {
      // If Firebase fails, return mock data
      return _getMockBookingData();
    }
  }

  // Fetch single booking details, or provide a mock if none found
  Future<BookingDetailsDto> getSingleBooking(String id) async {
    try {
      //prueba data falsa
      return _getMockBookingDetails(id);
      //data real
      /*
      final doc = await _firestore.collection('bookings').doc(id).get();
      if (!doc.exists) {
        throw Exception('Booking not found');
      }
      return BookingDetailsDto.fromMap(doc.data() as Map<String, dynamic>);*/
    } catch (e) {
      // Provide mock details if no booking is found
      return _getMockBookingDetails(id);
    }
  }

// Accept a booking by updating its status to 'accepted' in Firestore
  Future<void> acceptBooking(String id) async {
    try {
      await _firestore.collection('bookings').doc(id).update({
        'status': 'accepted',
      });
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  // Decline a booking by updating its status to 'declined' in Firestore
  Future<void> declineBooking(String id) async {
    try {
      await _firestore.collection('bookings').doc(id).update({
        'status': 'declined',
      });
    } catch (e) {
      throw Exception('Failed to decline booking: $e');
    }
  }

  // Mock data for provider bookings
  ProviderBookingDto _getMockBookingData() {
    final bookings = [
      BookingDataDto(
        id: 1,
        orderId: 1001,
        clientId: 101,
        providerId: 201,
        serviceId: 301,
        packageAmount: 120.0,
        totalAmount: 140.0,
        bookingDate: '2024-09-18',
        appointmentSchedule: 'Morning',
        scheduleTimeSlot: '10:00 AM - 11:00 AM',
        additionalAmount: 20.0,
        paymentMethod: 'Credit Card',
        paymentStatus: 'Paid',
        refundStatus: 0,
        transectionId: 'ABC123',
        orderStatus: 'approved',
        orderApprovalDate: '',
        orderCompletedDate: '',
        orderDeclinedDate: '',
        packageFeatures: 'Standard Package',
        additionalServices: 'Extra Cleaning',
        clientAddress: '123 Street, City',
        orderNote: 'Please arrive on time',
        completeByAdmin: '',
        createdAt: '2024-09-01',
        updatedAt: '2024-09-05',
        client: ClientInfoDto(
          id: 101,
          name: 'John Doe',
          email: 'john.doe@example.com',
          image: 'https://via.placeholder.com/150',
          phone: '555-555-5555',
          address: '123 Street, City',
        ),
        service: ServiceItem(
          id: 1,
          name: "Featured Service 1",
          slug: "featured-service-1",
          image: KImages.s01,
          price: 100.0,
          categoryId: categories[0],
          providerId: 1,
          makeFeatured: 1,
          isBanned: 0,
          details: "This is a featured service by John Doe",
          status: 1,
          createdAt: "2024-01-01",
          approveByAdmin: 1,
          averageRating: "5",
          totalReview: 10,
          totalOrder: 5,
          category: categories[0],
          provider: ProviderModel(
            id: 1,
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "5551234567",
            image: KImages.pp,
            createdAt: "2024-08-01",
            userName: "johndoe",
            rating: 4.9,
            reviews: 50,
            timeSlots: [
              TimeSlotModel(time: "08:00", isAvailable: true),
              TimeSlotModel(time: "08:30", isAvailable: false),
              TimeSlotModel(time: "09:00", isAvailable: true),
              TimeSlotModel(time: "09:30", isAvailable: true),
              TimeSlotModel(time: "10:00", isAvailable: false),
              TimeSlotModel(time: "10:30", isAvailable: true),
              TimeSlotModel(time: "11:00", isAvailable: true),
              TimeSlotModel(time: "11:30", isAvailable: false),
              TimeSlotModel(time: "12:00", isAvailable: true),
              TimeSlotModel(time: "12:30", isAvailable: true),
              TimeSlotModel(time: "01:00", isAvailable: true),
              TimeSlotModel(time: "01:30", isAvailable: false),
            ],
            profession: 'Cleaning',
          ),
          // John Doe
        ),
      ),
      BookingDataDto(
        id: 1,
        orderId: 1001,
        clientId: 101,
        providerId: 201,
        serviceId: 301,
        packageAmount: 120.0,
        totalAmount: 140.0,
        bookingDate: '2024-09-18',
        appointmentSchedule: 'Morning',
        scheduleTimeSlot: '10:00 AM - 11:00 AM',
        additionalAmount: 20.0,
        paymentMethod: 'Credit Card',
        paymentStatus: 'Paid',
        refundStatus: 0,
        transectionId: 'ABC123',
        orderStatus: 'awaiting',
        orderApprovalDate: '',
        orderCompletedDate: '',
        orderDeclinedDate: '',
        packageFeatures: 'Standard Package',
        additionalServices: 'Extra Cleaning',
        clientAddress: '123 Street, City',
        orderNote: 'Please arrive on time',
        completeByAdmin: '',
        createdAt: '2024-09-01',
        updatedAt: '2024-09-05',
        client: ClientInfoDto(
          id: 101,
          name: 'John Doe',
          email: 'john.doe@example.com',
          image: 'https://via.placeholder.com/150',
          phone: '555-555-5555',
          address: '123 Street, City',
        ),
        service: ServiceItem(
          id: 1,
          name: "Featured Service 1",
          slug: "featured-service-1",
          image: KImages.s01,
          price: 100.0,
          categoryId: categories[0],
          providerId: 1,
          makeFeatured: 1,
          isBanned: 0,
          details: "This is a featured service by John Doe",
          status: 1,
          createdAt: "2024-01-01",
          approveByAdmin: 1,
          averageRating: "5",
          totalReview: 10,
          totalOrder: 5,
          category: categories[0],
          provider: ProviderModel(
            id: 1,
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "5551234567",
            image: KImages.pp,
            createdAt: "2024-08-01",
            userName: "johndoe",
            rating: 4.9,
            reviews: 50,
            timeSlots: [
              TimeSlotModel(time: "08:00", isAvailable: true),
              TimeSlotModel(time: "08:30", isAvailable: false),
              TimeSlotModel(time: "09:00", isAvailable: true),
              TimeSlotModel(time: "09:30", isAvailable: true),
              TimeSlotModel(time: "10:00", isAvailable: false),
              TimeSlotModel(time: "10:30", isAvailable: true),
              TimeSlotModel(time: "11:00", isAvailable: true),
              TimeSlotModel(time: "11:30", isAvailable: false),
              TimeSlotModel(time: "12:00", isAvailable: true),
              TimeSlotModel(time: "12:30", isAvailable: true),
              TimeSlotModel(time: "01:00", isAvailable: true),
              TimeSlotModel(time: "01:30", isAvailable: false),
            ],
            profession: 'Cleaning',
          ),
          // John Doe
        ),
      ),
    ];

    return ProviderBookingDto(
      title: 'Provider Bookings (Mock)',
      orders: bookings,
      currencyIconModel: CurrencyIconModel(icon: 'default_icon'),
      declienedBooking:
          bookings.where((b) => b.orderStatus == 'declined').length,
      totalAwaiting: bookings.where((b) => b.orderStatus == 'awaiting').length,
      activeBooking: bookings.where((b) => b.orderStatus == 'active').length,
      completeBooking:
          bookings.where((b) => b.orderStatus == 'complete').length,
    );
  }

  // Mock data for booking details
  BookingDetailsDto _getMockBookingDetails(String id) {
    return BookingDetailsDto(
      orders: BookingDataDto(
        id: 1,
        orderId: int.parse(id),
        clientId: 101,
        providerId: 201,
        serviceId: 301,
        packageAmount: 120.0,
        totalAmount: 140.0,
        bookingDate: '2024-09-18',
        appointmentSchedule: 'Morning',
        scheduleTimeSlot: '10:00 AM - 11:00 AM',
        additionalAmount: 20.0,
        paymentMethod: 'Credit Card',
        paymentStatus: 'Paid',
        refundStatus: 0,
        transectionId: 'ABC123',
        orderStatus: 'awaiting',
        orderApprovalDate: '',
        orderCompletedDate: '',
        orderDeclinedDate: '',
        packageFeatures: 'Standard Package',
        additionalServices: 'Extra Cleaning',
        clientAddress: '123 Street, City',
        orderNote: 'Please arrive on time',
        completeByAdmin: '',
        createdAt: '2024-09-01',
        updatedAt: '2024-09-05',
        client: ClientInfoDto(
          id: 101,
          name: 'John Doe',
          email: 'john.doe@example.com',
          image: 'https://via.placeholder.com/150',
          phone: '555-555-5555',
          address: '123 Street, City',
        ),
        service: ServiceItem(
          id: 1,
          name: "Featured Service 1",
          slug: "featured-service-1",
          image: KImages.s01,
          price: 100.0,
          categoryId: categories[0],
          providerId: 1,
          makeFeatured: 1,
          isBanned: 0,
          details: "This is a featured service by John Doe",
          status: 1,
          createdAt: "2024-01-01",
          approveByAdmin: 1,
          averageRating: "5",
          totalReview: 10,
          totalOrder: 5,
          category: categories[0],
          provider: ProviderModel(
            id: 1,
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "5551234567",
            image: KImages.pp,
            createdAt: "2024-08-01",
            userName: "johndoe",
            rating: 4.9,
            reviews: 50,
            timeSlots: [
              TimeSlotModel(time: "08:00", isAvailable: true),
              TimeSlotModel(time: "08:30", isAvailable: false),
              TimeSlotModel(time: "09:00", isAvailable: true),
              TimeSlotModel(time: "09:30", isAvailable: true),
              TimeSlotModel(time: "10:00", isAvailable: false),
              TimeSlotModel(time: "10:30", isAvailable: true),
              TimeSlotModel(time: "11:00", isAvailable: true),
              TimeSlotModel(time: "11:30", isAvailable: false),
              TimeSlotModel(time: "12:00", isAvailable: true),
              TimeSlotModel(time: "12:30", isAvailable: true),
              TimeSlotModel(time: "01:00", isAvailable: true),
              TimeSlotModel(time: "01:30", isAvailable: false),
            ],
            profession: 'Cleaning',
          ),
          // John Doe
        ),
      ),
      bookingAddress: BookingAddress(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '555-555-5555',
        address: '123 Street, City',
        postCode: '12345',
        orderNote: 'Please arrive on time',
      ),
      packageFeatures: ['Standard Package', 'Window Cleaning'],
      additionalServices: [
        AdditionalServices(
          id: 1,
          serviceId: 301,
          serviceName: 'Extra Cleaning',
          image: 'https://via.placeholder.com/150',
          qty: 1,
          price: 20,
          createdAt: '2024-09-01',
          updatedAt: '2024-09-01',
        ),
      ],
    );
  }
}
