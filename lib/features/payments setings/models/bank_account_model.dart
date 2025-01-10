// bank_account_model.dart

import 'package:encrypt/encrypt.dart'; // Importar paquete de cifrado

class BankAccountModel {
  final String id;
  final String bankName;
  final String branchCode;
  final String accountNumber; // Cifrado
  final String routingNumber; // Cifrado
  final String accountHolderName;
  final String accountType; // 'Checking' o 'Savings'
  final String ownerType; // 'client' o 'provider'
  final String userId; // ID del usuario asociado
  final String email; // Email del usuario asociado

  BankAccountModel({
    required this.id,
    required this.branchCode,
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderName,
    required this.accountType,
    required this.ownerType,
    required this.userId,
    required this.email,
  });

  /// Factory para crear una instancia desde JSON
  factory BankAccountModel.fromJson(
      Map<String, dynamic> json, Encrypter encrypter) {
    return BankAccountModel(
      id: json['id'],
      branchCode: json['branchCode'],
      bankName: json['bank_name'],
      accountNumber: encrypter.decrypt64(json['accountNumber']),
      routingNumber: encrypter.decrypt64(json['routingNumber']),
      accountHolderName: json['account_holder_name'],
      accountType: json['account_type'],
      ownerType: json['owner_type'],
      userId: json['user_id'],
      email: json['email'],
    );
  }

  /// Convertir una instancia a JSON con cifrado
  Map<String, dynamic> toJson(Encrypter encrypter) {
    return {
      'id': id,
      'branchCode': branchCode,
      'bank_name': bankName,
      'accountNumber': encrypter.encrypt(accountNumber).base64,
      'routingNumber': encrypter.encrypt(routingNumber).base64,
      'account_holder_name': accountHolderName,
      'account_type': accountType,
      'owner_type': ownerType,
      'user_id': userId,
      'email': email,
    };
  }
}
