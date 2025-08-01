import 'dart:io';

import 'package:flutter/material.dart';

class AppValidator {
  // Static error notifiers
  static final ValueNotifier<String?> emailError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> passwordError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> nameError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> otherNameError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> phoneError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> dateOfBirthError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> addressError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> cityError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> requiredFieldError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> bioDescriptionError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> usernameError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> licenseImageError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> vehicleRegistrationImageError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> driverImageError = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> imageError = ValueNotifier<String?>(null);

  // Static validation methods
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      emailError.value = 'Phone number or email is required';
      return emailError.value;
    }
    if (!_isValidEmail(value) && !_isValidPhoneNumber(value)) {
      emailError.value = 'Enter a valid email address';
      return emailError.value;
    }
    emailError.value = null;
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      passwordError.value = 'Password is required';
      return passwordError.value;
    }
    if (value.length < 8) {
      passwordError.value = 'Password must be at least 8 characters long';
      return passwordError.value;
    }

    passwordError.value = null;
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      nameError.value = 'Full name is required';
      return nameError.value;
    }
    if (value.length < 2) {
      nameError.value = 'Name must be at least 2 characters long';
      return nameError.value;
    }
    if (!_isValidName(value)) {
      nameError.value = 'Name can only contain letters and spaces';
      return nameError.value;
    }
    nameError.value = null;
    return null;
  }

  static String? validateOtherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      otherNameError.value = 'Other name is required';
      return otherNameError.value;
    }
    if (value.length < 2) {
      otherNameError.value = 'Name must be at least 2 characters long';
      return otherNameError.value;
    }
    if (!_isValidName(value)) {
      otherNameError.value = 'Name can only contain letters and spaces';
      return otherNameError.value;
    }
    otherNameError.value = null;
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      phoneError.value = 'Phone number is required';
      return phoneError.value;
    }
    if (!_isValidPhoneNumber(value)) {
      phoneError.value = 'Enter a valid phone number';
      return phoneError.value;
    }
    phoneError.value = null;
    return null;
  }


  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      dateOfBirthError.value = 'Date of birth is required';
      return dateOfBirthError.value;
    }
    final now = DateTime.now();
    final age = now.difference(value).inDays ~/ 365;
    if (age < 18) {
      dateOfBirthError.value = 'You must be at least 18 years old';
      return dateOfBirthError.value;
    }
    dateOfBirthError.value = null;
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      addressError.value = 'Address is required';
      return addressError.value;
    }
    if (value.length < 5) {
      addressError.value = 'Address must be at least 5 characters long';
      return addressError.value;
    }
    addressError.value = null;
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      cityError.value = 'City is required';
      return cityError.value;
    }
    cityError.value = null;
    return null;
  }
  static String? validateImage(File? image) {
    if (image == null) {
      imageError.value = 'Please select a profile image';
      return imageError.value;
    }
    imageError.value = null;
    return null;
  }
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      requiredFieldError.value = '$fieldName is required';
      return requiredFieldError.value;
    }
    requiredFieldError.value = null;
    return null;
  }


  static String? validateBioDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      bioDescriptionError.value = 'Bio description is required';
      return bioDescriptionError.value;
    }
    if (value.length < 10) {
      bioDescriptionError.value = 'Bio description must be at least 10 characters';
      return bioDescriptionError.value;
    }
    if (value.length > 500) {
      bioDescriptionError.value = 'Bio description must not exceed 500 characters';
      return bioDescriptionError.value;
    }
    bioDescriptionError.value = null;
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      usernameError.value = 'Username is required';
      return usernameError.value;
    }
    if (value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
      return usernameError.value;
    }
    if (value.length > 30) {
      usernameError.value = 'Username must not exceed 30 characters';
      return usernameError.value;
    }
    if (!_isValidUsername(value)) {
      usernameError.value = 'Username can only contain letters, numbers, and underscores';
      return usernameError.value;
    }
    usernameError.value = null;
    return null;
  }




  // Static helpers
  static bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(value.trim());
  }

  static bool _isValidName(String value) {
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    return nameRegex.hasMatch(value.trim());
  }

  static bool _isValidPhoneNumber(String value) {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(value.trim());
  }



  static bool _isValidUsername(String value) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(value.trim());
  }

  static void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
    nameError.value = null;
    otherNameError.value = null;
    phoneError.value = null;
    dateOfBirthError.value = null;
    addressError.value = null;
    cityError.value = null;
    requiredFieldError.value = null;

    bioDescriptionError.value = null;
    usernameError.value = null;
    licenseImageError.value = null;
    vehicleRegistrationImageError.value = null;
    driverImageError.value = null;
  }

  static void dispose() {
    emailError.dispose();
    passwordError.dispose();
    nameError.dispose();
    otherNameError.dispose();
    phoneError.dispose();
    dateOfBirthError.dispose();
    addressError.dispose();
    cityError.dispose();
    requiredFieldError.dispose();
    bioDescriptionError.dispose();
    usernameError.dispose();
  }
}