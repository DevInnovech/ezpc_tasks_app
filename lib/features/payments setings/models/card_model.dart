// card_model.dart
class CardModel {
  final String id;
  final String last4;
  final String expMonth;
  final String expYear;
  final String brand;
  final String ownerType; // 'client' or 'provider'

  CardModel({
    required this.id,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.brand,
    required this.ownerType,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      last4: json['last4'],
      expMonth: json['exp_month'],
      expYear: json['exp_year'],
      brand: json['brand'],
      ownerType: json['owner_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'brand': brand,
      'owner_type': ownerType,
    };
  }
}
