import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_m_app/core/utils/theme/app_images.dart';
import 'dart:io';

import '../../../../../core/base/base_state.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/utils/theme/app_color.dart';
import '../../../../../core/utils/theme/app_text_style.dart';
import '../../../../../core/utils/validator/validator.dart';
import '../../../../../core/utils/widgets/custom_elevated_button.dart';
import '../../../../../core/utils/widgets/custom_text_field.dart';
import '../../../domain/entites/response/auth_result.dart';
import '../register_view_model/register_view_model.dart';

@RoutePage()
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterViewModel>(),
      child: BlocConsumer<RegisterViewModel, BaseState>(
        listener: (context, state) {
          if (state is SuccessState<AuthOutcome>) {
            // Navigate to next screen or show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            // Example: context.router.push(const HomeRoute());
          } else if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          final viewModel = context.read<RegisterViewModel>();

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: AppTextStyle.headlineSmall,
              ),
            ),
            body: Form(
              key: viewModel.formKey,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 56),
                children: [
                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: () => viewModel.pickProfileImage(),
                      child: ValueListenableBuilder<File?>(
                        valueListenable: viewModel.profileImage,
                        builder: (context, image, _) {
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.grey,
                                  image: image != null
                                      ? DecorationImage(
                                    image: FileImage(image),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: image == null
                                    ? const Center(
                                  child: Icon(
                                    CupertinoIcons.person,
                                    size: 90,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // Image validation error message
                  ValueListenableBuilder(
                    valueListenable: AppValidator.imageError,
                    builder: (context, imageError, _) {
                      return imageError != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          imageError,
                          style: AppTextStyle.error,
                          textAlign: TextAlign.center,
                        ),
                      )
                          : const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 30),
                  // Full Name
                  ValueListenableBuilder(
                    valueListenable: AppValidator.nameError,
                    builder: (context, nameError, _) {
                      return CustomTextField(
                        hintText: 'Full Name',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        controller: viewModel.fullNameController,
                        validator: (value) => AppValidator.validateName(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Username
                  ValueListenableBuilder(
                    valueListenable: AppValidator.usernameError,
                    builder: (context, usernameError, _) {
                      return CustomTextField(
                        hintText: 'Username',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        controller: viewModel.usernameController,
                        validator: (value) => AppValidator.validateUsername(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone Number
                  ValueListenableBuilder(
                    valueListenable: AppValidator.phoneError,
                    builder: (context, phoneError, _) {
                      return CustomTextField(
                        hintText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: viewModel.phoneController,
                        validator: (value) => AppValidator.validatePhoneNumber(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email
                  ValueListenableBuilder(
                    valueListenable: AppValidator.emailError,
                    builder: (context, emailError, _) {
                      return CustomTextField(
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        controller: viewModel.emailController,
                        validator: (value) => AppValidator.validateEmail(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password
                  ValueListenableBuilder(
                    valueListenable: AppValidator.passwordError,
                    builder: (context, passwordError, _) {
                      return CustomTextField(
                        hintText: 'Password',
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        controller: viewModel.passwordController,
                        obscureText: true,
                        validator: (value) => AppValidator.validatePassword(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Bio
                  ValueListenableBuilder(
                    valueListenable: AppValidator.bioDescriptionError,
                    builder: (context, bioError, _) {
                      return CustomTextField(
                        hintText: 'Bio',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        controller: viewModel.bioController,
                        maxLines: 3,
                        validator: (value) => AppValidator.validateBioDescription(value),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      borderRadius: BorderRadius.circular(24),
                      text: 'Create Account',
                      onPressed: state is LoadingState
                          ? null
                          : () {
                        viewModel.register();
                      },
                      isLoading: state is LoadingState,
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}