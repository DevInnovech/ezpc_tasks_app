class OrderDetailsDto {
  final String orderId;
  final String taskName;
  final String providerId;
  final String providerName;
  final String providerImageUrl;
  final String date;
  final String time;
  final double price;
  final double discount;
  final double tax;
  final double total;
  final String status;
  final String providerStatus;
  final String address;
  final String providerEmail;
  final String providerPhone;
  final double rating; // Calificación del proveedor
  final String paymentStatus;
  final Map<String, dynamic>? extraTime; // Mapa consolidado para ExtraTime

  OrderDetailsDto({
    required this.orderId,
    required this.taskName,
    required this.providerName,
    required this.providerId,
    required this.providerImageUrl,
    required this.date,
    required this.time,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    required this.providerStatus,
    required this.address,
    required this.providerEmail,
    required this.providerPhone,
    required this.rating,
    required this.paymentStatus,
    this.extraTime, // ExtraTime opcional
  });

  // Método para convertir un Map a una instancia de OrderDetailsDto
  factory OrderDetailsDto.fromMap(Map<String, dynamic> map) {
    return OrderDetailsDto(
      orderId: map['id'] ?? '',
      taskName: map['taskName'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      providerImageUrl: map['providerImageUrl'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      total: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      providerStatus: map['ProviderStatus'] ?? '',
      address: map['address'] ?? '',
      providerEmail: map['providerEmail'] ?? '',
      providerPhone: map['providerPhone'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] ?? '',
      extraTime:
          map['extraTime'], // Asignar el mapa completo de extraTime si existe
    );
  }

  // Método para convertir una instancia a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': orderId,
      'taskName': taskName,
      'providerId': providerId,
      'providerName': providerName,
      'providerImageUrl': providerImageUrl,
      'date': date,
      'time': time,
      'price': price,
      'discount': discount,
      'tax': tax,
      'total': total,
      'status': status,
      'ProviderStatus': providerStatus,
      'address': address,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'rating': rating,
      'paymentStatus': paymentStatus,
      'extraTime': extraTime, // Convertir el mapa de extraTime si existe
    };
  }
}
