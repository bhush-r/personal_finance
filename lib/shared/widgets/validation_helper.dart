class ValidationHelper {
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
    return null;
  }

  static String? validateNote(String? value) {
    if ((value?.length ?? 0) > 500) {
      return 'Note must be less than 500 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}