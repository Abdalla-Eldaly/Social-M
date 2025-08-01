import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../../../../core/base/base_state.dart';
import '../../../../../core/utils/Functions/image_picker.dart';
import '../../../../../core/utils/validator/validator.dart';
import '../../../domain/entites/response/auth_result.dart';
import '../../../domain/usecases/register_usecases.dart';

@injectable
class RegisterViewModel extends Cubit<BaseState> {
  final RegisterUseCase _registerUseCase;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<File?> _profileImage = ValueNotifier<File?>(null);

  RegisterViewModel(this._registerUseCase) : super(InitialState());

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get bioController => _bioController;
  GlobalKey<FormState> get formKey => _formKey;
  ValueNotifier<String?> get roleError => AppValidator.requiredFieldError;
  ValueNotifier<File?> get profileImage => _profileImage;

  Future<void> pickProfileImage() async {
    await ImagePickerUtils.pickImage((image) {
      _profileImage.value = image;
      AppValidator.imageError.value = null;
    });
  }

  Future<void> register() async {
    AppValidator.clearErrors();

    if (_profileImage.value == null) {
      AppValidator.imageError.value = 'Profile image is required';
    }

    AppValidator.validateName(_fullNameController.text.trim());
    AppValidator.validateUsername(_usernameController.text.trim());
    AppValidator.validateEmail(_emailController.text.trim());
    AppValidator.validatePassword(_passwordController.text.trim());
    AppValidator.validateBioDescription(_bioController.text.trim());

    if (!_formKey.currentState!.validate() ||
        AppValidator.requiredFieldError.value != null ||
        AppValidator.imageError.value != null ||
        AppValidator.usernameError.value != null ||
        AppValidator.bioDescriptionError.value != null) {
      emit(const ErrorState('Please correct the errors in the form.'));
      return;
    }

    emit(LoadingState());

    try {
      final result = await _registerUseCase.execute((
      name: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      bio: _bioController.text.trim(),
      profileImage: _profileImage.value!,
      ));

      result.fold(
            (failure) => emit(ErrorState(failure.message)),
            (authOutcome) => emit(SuccessState<AuthOutcome>(authOutcome)),
      );
    } catch (e) {
      emit(ErrorState('Registration failed: $e'));
    }
  }

  void clearForm() {
    _fullNameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _bioController.clear();
    _profileImage.value = null;
    AppValidator.clearErrors();
    emit(InitialState());
  }

  @override
  Future<void> close() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _profileImage.dispose();
    return super.close();
  }
}