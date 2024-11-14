// mock_data.dart
import '../models/bank_account_model.dart';
import '../models/card_model.dart';

// Mock data for cards
final mockCards = [
  CardModel(
    id: "card_1",
    last4: "1111",
    expMonth: "12",
    expYear: "2024",
    brand: "Visa",
    ownerType: "client",
    cardHolderName: 'juan',
    zipCode: '01843',
  ),
  CardModel(
    id: "card_2",
    last4: "2222",
    expMonth: "11",
    expYear: "2025",
    brand: "MasterCard",
    ownerType: "provider",
    cardHolderName: 'juan',
    zipCode: '01843',
  ),
  CardModel(
    id: "card_3",
    last4: "3333",
    expMonth: "08",
    expYear: "2026",
    brand: "Amex",
    ownerType: "client",
    cardHolderName: 'juan',
    zipCode: '01843',
  ),
];

// Mock data for bank accounts
final mockBankAccounts = [
  BankAccountModel(
    id: "account_1",
    accountNumber: "1234",
    bankName: "Bank A",
    ownerType: "provider",
    accountHolderName: 'juan acosta',
    branchCode: '2867',
  ),
  BankAccountModel(
    id: "account_2",
    accountNumber: "*5678",
    bankName: "Bank B",
    ownerType: "client",
    accountHolderName: 'juan acosta',
    branchCode: '2867',
  ),
  BankAccountModel(
    id: "account_3",
    accountNumber: "9101",
    bankName: "Bank C",
    ownerType: "provider",
    accountHolderName: 'juan acosta',
    branchCode: '2867',
  ),
];
