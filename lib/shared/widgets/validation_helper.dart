class ValidationHelper {
  // ✨ AMOUNT VALIDATION
  static String? validateAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value!);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 10000000) {
      return 'Amount is too large';
    }
    return null;
  }

  // ✨ NAME VALIDATION
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Name is required';
    }
    if ((value?.length ?? 0) < 2) {
      return 'Name must be at least 2 characters';
    }
    if ((value?.length ?? 0) > 50) {
      return 'Name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
      return 'Name can only contain letters';
    }
    return null;
  }

  // ✨ NOTE VALIDATION
  static String? validateNote(String? value) {
    if ((value?.length ?? 0) > 500) {
      return 'Note must be less than 500 characters';
    }
    return null;
  }

  // ✨ EMAIL VALIDATION
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // ✨ PASSWORD VALIDATION
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value!)) {
      return 'Password must contain uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain number';
    }
    return null;
  }

  // ✨ PHONE VALIDATION
  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value!.replaceAll(RegExp(r'\D'), ''))) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  // ✨ URL VALIDATION
  static String? validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value!)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // ✨ PINCODE VALIDATION (India)
  static String? validatePincode(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value!)) {
      return 'Pincode must be 6 digits';
    }
    return null;
  }

  // ✨ CREDIT CARD VALIDATION
  static String? validateCreditCard(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Card number is required';
    }
    final cardNumber = value!.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cardNumber)) {
      return 'Invalid card number';
    }
    return null;
  }

  // ✨ CUSTOM VALIDATION
  static String? validateCustom(
      String? value, {
        required String emptyMessage,
        required bool Function(String) isValid,
        required String invalidMessage,
      }) {
    if (value?.isEmpty ?? true) {
      return emptyMessage;
    }
    if (!isValid(value!)) {
      return invalidMessage;
    }
    return null;
  }
}