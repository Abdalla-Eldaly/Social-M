import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import '../../../../../core/utils/network/network_exception.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

class CreatePostInitial extends CreatePostState {}

class CreatePostLoading extends CreatePostState {
  final String? message;

  const CreatePostLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class CreatePostImageSelected extends CreatePostState {
  final File imageFile;
  final String caption;
  final List<String> hashtags;
  final CustomLocationData? locationData;
  final LocationPermissionStatus locationPermissionStatus;
  final String? locationError;

  const CreatePostImageSelected({
    required this.imageFile,
    this.caption = '',
    this.hashtags = const [],
    this.locationData,
    this.locationPermissionStatus = LocationPermissionStatus.unknown,
    this.locationError,
  });

  CreatePostImageSelected copyWith({
    File? imageFile,
    String? caption,
    List<String>? hashtags,
    CustomLocationData? locationData,
    LocationPermissionStatus? locationPermissionStatus,
    String? locationError,
    bool clearLocationData = false,
    bool clearLocationError = false,
  }) {
    return CreatePostImageSelected(
      imageFile: imageFile ?? this.imageFile,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      locationData: clearLocationData ? null : (locationData ?? this.locationData),
      locationPermissionStatus: locationPermissionStatus ?? this.locationPermissionStatus,
      locationError: clearLocationError ? null : (locationError ?? this.locationError),
    );
  }

  bool get hasValidData {
    return imageFile.existsSync() && caption.trim().isNotEmpty && hashtags.isNotEmpty;
  }

  bool get canSubmit {
    return imageFile.existsSync() && caption.trim().isNotEmpty;
  }

  @override
  List<Object?> get props => [
    imageFile,
    caption,
    hashtags,
    locationData,
    locationPermissionStatus,
    locationError,
  ];
}

class CreatePostSubmitting extends CreatePostState {
  final String? progressMessage;

  const CreatePostSubmitting({this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

class CreatePostSuccess extends CreatePostState {
  final Post post;
  final String? message;

  const CreatePostSuccess(this.post, {this.message});

  @override
  List<Object?> get props => [post, message];
}

class CreatePostError extends CreatePostState {
  final String message;
  final NetworkException? networkException;
  final CreatePostErrorType errorType;
  final Map<String, List<String>>? fieldErrors;
  final bool canRetry;

  const CreatePostError({
    required this.message,
    this.networkException,
    this.errorType = CreatePostErrorType.unknown,
    this.fieldErrors,
    this.canRetry = true,
  });

   factory CreatePostError.network({
    required NetworkException networkException,
    bool canRetry = true,
  }) {
    return CreatePostError(
      message: networkException.userFriendlyMessage,
      networkException: networkException,
      errorType: CreatePostErrorType.network,
      fieldErrors: networkException.validationErrors,
      canRetry: canRetry && !networkException.isClientError,
    );
  }

  factory CreatePostError.validation({
    required String message,
    required Map<String, List<String>> fieldErrors,
  }) {
    return CreatePostError(
      message: message,
      errorType: CreatePostErrorType.validation,
      fieldErrors: fieldErrors,
      canRetry: false,
    );
  }

  factory CreatePostError.permission({
    required String message,
  }) {
    return CreatePostError(
      message: message,
      errorType: CreatePostErrorType.permission,
      canRetry: false,
    );
  }

  factory CreatePostError.fileSystem({
    required String message,
  }) {
    return CreatePostError(
      message: message,
      errorType: CreatePostErrorType.fileSystem,
      canRetry: true,
    );
  }

  factory CreatePostError.location({
    required String message,
  }) {
    return CreatePostError(
      message: message,
      errorType: CreatePostErrorType.location,
      canRetry: true,
    );
  }

  // Convenience getters
  bool get isValidationError => errorType == CreatePostErrorType.validation ||
      (networkException?.isValidationError ?? false);
  bool get isNetworkError => errorType == CreatePostErrorType.network;
  bool get isPermissionError => errorType == CreatePostErrorType.permission;
  bool get isLocationError => errorType == CreatePostErrorType.location;
  bool get isFileSystemError => errorType == CreatePostErrorType.fileSystem;

  // Get errors for specific field
  List<String>? getFieldErrors(String fieldName) {
    return fieldErrors?[fieldName] ?? networkException?.getFieldErrors(fieldName);
  }

  // Check if specific field has errors
  bool hasFieldError(String fieldName) {
    return fieldErrors?.containsKey(fieldName) ??
        networkException?.hasFieldError(fieldName) ?? false;
  }

  String get userInstructions {
    if (networkException?.instructions != null) {
      return networkException!.instructions!;
    }

    switch (errorType) {
      case CreatePostErrorType.validation:
        return 'Please correct the highlighted errors and try again.';
      case CreatePostErrorType.network:
        return 'Please check your internet connection and try again.';
      case CreatePostErrorType.permission:
        return 'Please grant the required permissions in your device settings.';
      case CreatePostErrorType.location:
        return 'Please enable location services and try again.';
      case CreatePostErrorType.fileSystem:
        return 'Please check your device storage and try again.';
      case CreatePostErrorType.unknown:
        return 'Please try again or contact support if the issue persists.';
    }
  }

  @override
  List<Object?> get props => [
    message,
    networkException,
    errorType,
    fieldErrors,
    canRetry,
  ];
}

enum CreatePostErrorType {
  network,
  validation,
  permission,
  location,
  fileSystem,
  unknown,
}

enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class CustomLocationData extends Equatable {
  final double latitude;
  final double longitude;
  final double altitude;
  final double heading;

  const CustomLocationData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.heading,
  });

  bool get isValid {
    return latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180;
  }

  @override
  List<Object?> get props => [latitude, longitude, altitude, heading];

  @override
  String toString() {
    return 'CustomLocationData(lat: ${latitude.toStringAsFixed(6)}, '
        'lng: ${longitude.toStringAsFixed(6)}, '
        'alt: ${altitude.toStringAsFixed(2)}, '
        'heading: ${heading.toStringAsFixed(2)})';
  }
}