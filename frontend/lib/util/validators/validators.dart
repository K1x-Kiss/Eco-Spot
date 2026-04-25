String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  return null;
}

String? validateSurname(String? value) {
  if (value == null || value.isEmpty) {
    return 'Surname is required';
  }
  return null;
}

String? validateRole(String? value) {
  const validRoles = ['TOURIST', 'HOST', 'BUSINESS', 'EXPERIENCE'];
  if (value == null || value.isEmpty) {
    return 'Role is required';
  }
  if (!validRoles.contains(value)) {
    return 'Invalid role';
  }
  return null;
}

String? validateNameMax100(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  if (value.length > 100) {
    return 'Name must be 100 characters or less';
  }
  return null;
}

String? validateDescription300(String? value) {
  if (value != null && value.length > 300) {
    return 'Description must be 300 characters or less';
  }
  return null;
}

String? validatePhone10Digits(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone is required';
  }
  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length != 10) {
    return 'Phone must be 10 digits';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Password confirmation is required';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
