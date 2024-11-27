class ClientModel {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String imageUrl;
  final int totalBookings;
  final int completedBookings;
  final int activeBookings;

  ClientModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.imageUrl,
    required this.totalBookings,
    required this.completedBookings,
    required this.activeBookings,
  });
}
