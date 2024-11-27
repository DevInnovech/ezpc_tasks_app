// bank_account_model.dart

class BankAccountModel {
  final String id;
  final String bankName;
  final String branchCode;
  final String accountNumber;
  final String accountHolderName;
  final String ownerType; // 'client' or 'provider'

  BankAccountModel({
    required this.id,
    required this.branchCode,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ownerType,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      branchCode: json['branchCode'],
      bankName: json['bank_name'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['account_holder_name'],
      ownerType: json['owner_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchCode': branchCode,
      'bank_name': bankName,
      'accountNumber': accountNumber,
      'account_holder_name': accountHolderName,
      'owner_type': ownerType,
    };
  }
}
