import 'package:ezpc_tasks_app/features/Review/review_data_model.dart';
import 'package:ezpc_tasks_app/features/Review/review_user.dart';
import 'package:ezpc_tasks_app/features/Ticket/ticket_model.dart';
import 'package:ezpc_tasks_app/features/home/models/currency_icon_model.dart';
import 'package:ezpc_tasks_app/features/home/models/default_avatar.dart';
import 'package:ezpc_tasks_app/features/home/models/user_prfile_model.dart';
import 'package:ezpc_tasks_app/features/home/models/userdash_model.dart';
import 'package:ezpc_tasks_app/features/order/models/order_model.dart';
import 'package:ezpc_tasks_app/features/services/data/dashboard_user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRoleProvider = StateProvider<String>((ref) {
  // Logic to determine user role, it can be client or provider
  return 'client'; // You can dynamically assign 'client' or 'provider'
});

// Future provider for client dashboard data
final clientDashBoardProfileProvider =
    FutureProvider<UserDashBoardModel>((ref) async {
  // Logic to fetch client dashboard data
  return await fetchClientProfile();
});

Future<UserDashBoardModel> fetchClientProfile() async {
  // Simula un retraso de 2 segundos para imitar una llamada API.
  await Future.delayed(const Duration(seconds: 2));

  // Datos simulados para los distintos modelos que conforman UserDashBoardModel
  const userProfile = UserProfileModel(
    id: 1,
    name: 'John Doe',
    image: 'https://example.com/profile-picture.jpg',
    email: 'johndoe@example.com',
    designation: 'Client',
    phone: '123-456-7890',
    countryId: 1,
    stateId: 2,
    cityId: 3,
    zipCode: '10001',
    emailVerifiedAt: '2023-01-01',
    status: 1,
    address: '123 Main Street',
    isVendor: 'no',
    emailVerified: 'yes',
    verifyToken: null,
    createdAt: '2023-01-01',
    updatedAt: '2023-01-01',
  );

  const defaultAvatar =
      DefaultAvatar(image: 'https://example.com/default-avatar.jpg');

  const orderData = OrderDataModel(
    data: [
      OrderItems(
        id: 1,
        orderId: 'ORD123456',
        clientId: 1,
        totalAmount: 100.0,
        bookingDate: '2023-09-01',
        orderStatus: 'completed',
      ),
    ],
  );

  const currencyIcon = CurrencyIconModel(icon: '\$');

  const reviews = ReviewDatModel(
    data: [
      ReviewItems(
        id: 1,
        serviceId: 101,
        userId: 1,
        providerId: 5,
        review: 'Excellent service!',
        rating: 5.0,
        status: 1,
        createdAt: '2023-09-10',
        updatedAt: '2023-09-10',
        reviewService: ReviewService(
          id: 101,
          name: 'Cleaning Service',
          slug: 'cleaning-service',
          image: 'https://example.com/service-image.jpg',
          averageRating: '4.8',
          totalReview: 120,
          totalOrder: 50,
        ),
        user: ReviewUser(
          id: 1,
          name: 'John Doe',
          email: 'johndoe@example.com',
          image: '',
          phone: '',
          designation: '',
          status: 1,
          isProvider: 1,
          stateId: 1,
          cityId: 1,
          address: '',
          createdAt: '',
        ),
      ),
    ],
  );

  const tickets = TicketDataModel(
    data: [
      TicketItems(
        id: 1,
        userId: 1,
        orderId: 101,
        subject: 'Issue with Service',
        ticketId: 1234,
        ticketFrom: 'Client',
        status: 'open',
        createdAt: '2023-09-05',
        updatedAt: '2023-09-06',
        unSeenUserMessage: 2,
        user: DashbaordUserProfile(
          id: 1,
          name: 'John Doe',
          email: 'johndoe@example.com',
          image: 'https://example.com/profile-picture.jpg',
          status: '',
          isProvider: '',
        ),
        order: OrderItems(
          id: 1,
          orderId: 'ORD123456',
          clientId: 1,
          totalAmount: 100.0,
          bookingDate: '2023-09-01',
          orderStatus: 'completed',
        ),
      ),
    ],
  );

  // Devuelve una instancia de UserDashBoardModel con los datos simulados.
  return UserDashBoardModel(
    user: userProfile,
    defaultAvatar: defaultAvatar,
    completeOrder: 5,
    activeOrder: 1,
    totalOrder: 6,
    orders: orderData,
    icon: currencyIcon,
    reviews: reviews,
    tickets: tickets,
  );
}
