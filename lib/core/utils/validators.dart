class Validators {
  Validators._();

  static String? notEmpty(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3)
      return 'Username must be at least 3 characters';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < min)
      return '$fieldName must be at least $min characters';
    return null;
  }
}
