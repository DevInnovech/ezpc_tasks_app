class Booking {
  final String id;
  final String taskId;
  final String taskName;
  final String providerId;
  final String providerName;
  final String customerId;
  final String customerName;
  final String address; // Dirección del cliente
  final String bookingDate;
  final String bookingSlot;
  final double price;
  final double tax;
  final double totalAmount;
  final double advanceAmount;
  final String status;

  Booking({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.providerId,
    required this.providerName,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.bookingDate,
    required this.bookingSlot,
    required this.price,
    required this.tax,
    required this.totalAmount,
    required this.advanceAmount,
    required this.status,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskName: map['taskName'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      address: map['address'] ?? '',
      bookingDate: map['bookingDate'] ?? '',
      bookingSlot: map['bookingSlot'] ?? '',
      price: map['price'] ?? 0.0,
      tax: map['tax'] ?? 0.0,
      totalAmount: map['totalAmount'] ?? 0.0,
      advanceAmount: map['advanceAmount'] ?? 0.0,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskName': taskName,
      'providerId': providerId,
      'providerName': providerName,
      'customerId': customerId,
      'customerName': customerName,
      'address': address,
      'bookingDate': bookingDate,
      'bookingSlot': bookingSlot,
      'price': price,
      'tax': tax,
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      'status': status,
    };
  }
}
