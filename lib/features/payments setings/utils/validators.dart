// validators.dart
class Validators {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    if (value.length < 16 || value.length > 19) {
      return 'Card number must be between 16 and 19 digits';
    }
    if (!RegExp(r'^\d{16,19}\$').hasMatch(value)) {
      return 'Invalid card number';
    }
    return null;
  }

  static String? validateExpirationMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiration month is required';
    }
    final intMonth = int.tryParse(value);
    if (intMonth == null || intMonth < 1 || intMonth > 12) {
      return 'Invalid expiration month';
    }
    return null;
  }

  static String? validateExpirationYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiration year is required';
    }
    final intYear = int.tryParse(value);
    if (intYear == null || intYear < DateTime.now().year) {
      return 'Expiration year must be current or future year';
    }
    return null;
  }

  static String? validateCVC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVC is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVC must be 3 or 4 digits';
    }
    if (!RegExp(r'^\d{3,4}\$').hasMatch(value)) {
      return 'Invalid CVC';
    }
    return null;
  }

  static String? validateBankAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    if (value.length < 10 || value.length > 17) {
      return 'Account number must be between 10 and 17 digits';
    }
    if (!RegExp(r'^\d{10,17}\$').hasMatch(value)) {
      return 'Invalid account number';
    }
    return null;
  }

  static String? validateRoutingNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Routing number is required';
    }
    if (value.length != 9) {
      return 'Routing number must be 9 digits';
    }
    if (!RegExp(r'^\d{9}\$').hasMatch(value)) {
      return 'Invalid routing number';
    }
    return null;
  }

  static String? validateAccountHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account holder name is required';
    }
    if (value.length < 3) {
      return 'Account holder name must be at least 3 characters';
    }
    return null;
  }
}
