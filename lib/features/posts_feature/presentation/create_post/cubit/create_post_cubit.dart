import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:social_m_app/features/posts_feature/domain/usecases/create_post_use_case.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/create_post_dto.dart';
import 'create_post_state.dart';

@injectable
class CreatePostCubit extends Cubit<CreatePostState> {
  final CreatePostUseCase _createPostUseCase;
  final ImagePicker _imagePicker = ImagePicker();
  final Location _location = Location();

  CreatePostCubit(this._createPostUseCase) : super(CreatePostInitial());

  Future<void> pickImage({required ImageSource source}) async {
    try {
      emit(const CreatePostLoading(message: 'Selecting image...'));

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Validate file exists and is accessible
        if (!await imageFile.exists()) {
          emit(CreatePostError.fileSystem(
            message: 'Selected image file is not accessible. Please try again.',
          ));
          return;
        }

        // Check file size (optional - add reasonable limits)
        final fileSize = await imageFile.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB limit
          emit(CreatePostError.fileSystem(
            message: 'Image file is too large. Please select a smaller image.',
          ));
          return;
        }

        emit(CreatePostImageSelected(imageFile: imageFile));

        // Auto-request location after image selection
        await _requestLocation();
      } else {
        emit(CreatePostInitial());
      }
    } on PlatformException catch (e) {
      emit(CreatePostError.permission(
        message: 'Permission denied: ${e.message ?? 'Unable to access camera/gallery'}',
      ));
    } catch (e) {
      emit(CreatePostError.fileSystem(
        message: 'Failed to pick image: ${e.toString()}',
      ));
    }
  }

  Future<void> _requestLocation() async {
    final currentState = state;
    if (currentState is! CreatePostImageSelected) return;

    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        _updateLocationStatus(
          currentState,
          null,
          LocationPermissionStatus.serviceDisabled,
          'Location services are disabled',
        );

        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // Check location permission
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _updateLocationStatus(
            currentState,
            null,
            LocationPermissionStatus.denied,
            'Location permission denied',
          );
          return;
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        _updateLocationStatus(
          currentState,
          null,
          LocationPermissionStatus.permanentlyDenied,
          'Location permission permanently denied. Please enable it in settings.',
        );
        return;
      }

      // Get current location
      LocationData locationData = await _location.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        final customLocationData = CustomLocationData(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          altitude: locationData.altitude ?? 0.0,
          heading: locationData.heading ?? 0.0,
        );

        if (customLocationData.isValid) {
          _updateLocationStatus(
            currentState,
            customLocationData,
            LocationPermissionStatus.granted,
            null,
          );
        } else {
          _updateLocationStatus(
            currentState,
            null,
            LocationPermissionStatus.denied,
            'Invalid location data received',
          );
        }
      } else {
        _updateLocationStatus(
          currentState,
          null,
          LocationPermissionStatus.denied,
          'Unable to retrieve location coordinates',
        );
      }
    } on PlatformException catch (e) {
      _updateLocationStatus(
        currentState,
        null,
        LocationPermissionStatus.denied,
        'Location error: ${e.message ?? 'Unknown platform error'}',
      );
    } catch (e) {
      _updateLocationStatus(
        currentState,
        null,
        LocationPermissionStatus.denied,
        'Failed to get location: ${e.toString()}',
      );
    }
  }

  void _updateLocationStatus(
      CreatePostImageSelected currentState,
      CustomLocationData? locationData,
      LocationPermissionStatus permissionStatus,
      String? error,
      ) {
    emit(currentState.copyWith(
      locationData: locationData,
      locationPermissionStatus: permissionStatus,
      locationError: error,
      clearLocationData: locationData == null,
      clearLocationError: error == null,
    ));
  }

  void updateCaption(String caption) {
    final currentState = state;
    if (currentState is CreatePostImageSelected) {
      emit(currentState.copyWith(caption: caption));
    }
  }

  void updateHashtags(List<String> hashtags) {
    final currentState = state;
    if (currentState is CreatePostImageSelected) {
      // Validate and clean hashtags
      final cleanHashtags = hashtags
          .where((tag) => tag.trim().isNotEmpty)
          .map((tag) => tag.trim().toLowerCase())
          .toSet() // Remove duplicates
          .toList();

      emit(currentState.copyWith(hashtags: cleanHashtags));
    }
  }

  void addHashtag(String hashtag) {
    final currentState = state;
    if (currentState is CreatePostImageSelected) {
      final cleanHashtag = hashtag.trim().toLowerCase();
      if (cleanHashtag.isNotEmpty && !currentState.hashtags.contains(cleanHashtag)) {
        final updatedHashtags = [...currentState.hashtags, cleanHashtag];
        emit(currentState.copyWith(hashtags: updatedHashtags));
      }
    }
  }

  void removeHashtag(String hashtag) {
    final currentState = state;
    if (currentState is CreatePostImageSelected) {
      final updatedHashtags = currentState.hashtags
          .where((tag) => tag != hashtag.trim().toLowerCase())
          .toList();
      emit(currentState.copyWith(hashtags: updatedHashtags));
    }
  }

  void toggleLocation() {
    final currentState = state;
    if (currentState is CreatePostImageSelected) {
      if (currentState.locationData != null) {
        // Remove location
        emit(currentState.copyWith(
          clearLocationData: true,
          clearLocationError: true,
          locationPermissionStatus: LocationPermissionStatus.unknown,
        ));
      } else {
        // Request location again
        _requestLocation();
      }
    }
  }

  // Validate form before submission
  bool _validateForm(CreatePostImageSelected state) {
    final errors = <String, List<String>>{};

    // Validate caption
    if (state.caption.trim().isEmpty) {
      errors['Caption'] = ['Caption is required'];
    } else if (state.caption.trim().length < 3) {
      errors['Caption'] = ['Caption must be at least 3 characters long'];
    }

    // Validate hashtags
    if (state.hashtags.isEmpty) {
      errors['Hashtags'] = ['At least one hashtag is required'];
    } else {
      final invalidHashtags = state.hashtags
          .where((tag) => tag.length < 2 || tag.length > 30)
          .toList();
      if (invalidHashtags.isNotEmpty) {
        errors['Hashtags'] = ['Hashtags must be between 2-30 characters'];
      }
    }

    // Validate image file
    if (!state.imageFile.existsSync()) {
      errors['Image'] = ['Image file is not accessible'];
    }

    if (errors.isNotEmpty) {
      emit(CreatePostError.validation(
        message: 'Please correct the following errors:',
        fieldErrors: errors,
      ));
      return false;
    }

    return true;
  }

  Future<void> createPost() async {
    final currentState = state;
    if (currentState is! CreatePostImageSelected) return;

    // Validate form
    if (!_validateForm(currentState)) return;

    try {
      emit(const CreatePostSubmitting(progressMessage: 'Uploading your post...'));

      final createPostDto = CreatePostDto(
        imageFile: currentState.imageFile,
        caption: currentState.caption.trim(),
        hashtags: currentState.hashtags,
        latitude: currentState.locationData?.latitude,
        longitude: currentState.locationData?.longitude,
        altitude: currentState.locationData?.altitude,
        angle: currentState.locationData?.heading,
      );

      final result = await _createPostUseCase.call(createPostDto);

      result.fold(
            (networkException) {
          emit(CreatePostError.network(
            networkException: networkException,
            canRetry: !networkException.isClientError,
          ));
        },
            (post) {
          emit(CreatePostSuccess(
            post,
            message: 'Post created successfully!',
          ));
        },
      );
    } on FileSystemException catch (e) {
      emit(CreatePostError.fileSystem(
        message: 'File access error: ${e.message}',
      ));
    } on PlatformException catch (e) {
      emit(CreatePostError.permission(
        message: 'Platform error: ${e.message ?? 'Unknown platform error'}',
      ));
    } catch (e) {
      emit(CreatePostError(
        message: 'Failed to create post: ${e.toString()}',
        errorType: CreatePostErrorType.unknown,
        canRetry: true,
      ));
    }
  }

  void reset() {
    emit(CreatePostInitial());
  }

  void retryFromError() {
    final currentState = state;
    if (currentState is CreatePostError && currentState.canRetry) {
      // If we were in the middle of creating a post, try again
      if (state is CreatePostError) {
        createPost();
      } else {
        emit(CreatePostInitial());
      }
    } else {
      emit(CreatePostInitial());
    }
  }

  // Helper method to retry specific operations
  void retryLastOperation() {
    final currentState = state;
    if (currentState is CreatePostError) {
      switch (currentState.errorType) {
        case CreatePostErrorType.network:
          createPost();
          break;
        case CreatePostErrorType.location:
          _requestLocation();
          break;
        case CreatePostErrorType.fileSystem:
        case CreatePostErrorType.permission:
          emit(CreatePostInitial());
          break;
        case CreatePostErrorType.validation:
        // Don't retry validation errors automatically
          break;
        case CreatePostErrorType.unknown:
          emit(CreatePostInitial());
          break;
      }
    }
  }

  // Method to clear specific field errors after user fixes them
  void clearFieldError(String fieldName) {
    final currentState = state;
    if (currentState is CreatePostError && currentState.fieldErrors != null) {
      final updatedErrors = Map<String, List<String>>.from(currentState.fieldErrors!);
      updatedErrors.remove(fieldName);

      if (updatedErrors.isEmpty) {
        // If no more errors, go back to previous valid state
        emit(CreatePostInitial());
      } else {
        emit(CreatePostError.validation(
          message: currentState.message,
          fieldErrors: updatedErrors,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    // Clean up resources if needed
    return super.close();
  }
}