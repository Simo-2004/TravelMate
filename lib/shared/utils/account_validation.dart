/// Pure validation rules for the account-creation form.
///
/// Each method returns null when the value is acceptable, or a human-readable
/// error message otherwise. Kept free of Flutter/plugin dependencies so the
/// rules are fully unit-testable.
class AccountValidation {
  const AccountValidation._();

  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 20;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 64;
  static const int nameMaxLength = 40;
  static const int descriptionMaxLength = 300;

  /// Usernames allow letters, digits, underscore and dot.
  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_.]+$');

  static String? validateUsername(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < usernameMinLength) {
      return 'Username must be at least $usernameMinLength characters';
    }
    if (trimmed.length > usernameMaxLength) {
      return 'Username must be at most $usernameMaxLength characters';
    }
    if (!_usernamePattern.hasMatch(trimmed)) {
      return 'Use only letters, numbers, "." or "_"';
    }

    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    if (value.length > passwordMaxLength) {
      return 'Password must be at most $passwordMaxLength characters';
    }

    return null;
  }

  /// Validates a required name field ([fieldLabel] is used in the message).
  static String? validateRequiredName(String value, String fieldLabel) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '$fieldLabel is required';
    }
    if (trimmed.length > nameMaxLength) {
      return '$fieldLabel must be at most $nameMaxLength characters';
    }

    return null;
  }

  static String? validateDescription(String value) {
    if (value.trim().length > descriptionMaxLength) {
      return 'Description must be at most $descriptionMaxLength characters';
    }

    return null;
  }
}
