/// Validator helper untuk form autentikasi & umum.
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value);
    if (requiredError != null) {
      return requiredError;
    }

    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value);
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }
}
