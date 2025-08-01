import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_m_app/core/config/router/app_router.dart';
import '../../../../../core/base/base_state.dart';
import '../../../../../core/utils/theme/app_color.dart';
import '../../../../../core/utils/theme/app_dialogs.dart';
import '../../../../../core/utils/theme/app_images.dart';
import '../../../../../core/utils/theme/app_text_style.dart';
import '../../../../../core/utils/validator/validator.dart';
import '../../../../../core/utils/widgets/custom_elevated_button.dart';
import '../../../../../core/utils/widgets/custom_text_field.dart';
import '../login_view_model/login_view_model.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: viewModel.formKey,
              child: ListView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Welcome Back',
                    style: AppTextStyle.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 56),
                  ValueListenableBuilder<String?>(
                    valueListenable: viewModel.emailError,
                    builder: (context, emailError, _) {
                      return CustomTextField(
                        controller: viewModel.emailController,
                        hintText: 'UserName',
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        validator: (value) => AppValidator.validateUsername(value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String?>(
                    valueListenable: viewModel.passwordError,
                    builder: (context, passwordError, _) {
                      return CustomTextField(
                        controller: viewModel.passwordController,
                        hintText: 'Password',
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        validator: (value) => AppValidator.validatePassword(value),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  BlocConsumer<LoginViewModel, BaseState>(
                    listener: (context, state) {
                      if (state is SuccessState) {
                        AppDialogs.showSuccessToast('Login Successful!');
                      } else if (state is ErrorState) {
                        AppDialogs.showErrorToast(state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          borderRadius: BorderRadius.circular(24),
                          text: 'Login',
                          onPressed: state is LoadingState
                              ? null
                              : () {
                            if (viewModel.formKey.currentState!
                                .validate()) {
                              viewModel.login(
                                viewModel.emailController.text.trim(),
                                viewModel.passwordController.text.trim(),
                              );
                            }
                          },
                          isLoading: state is LoadingState,
                          isPrimary: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Or continue with',
                          style: AppTextStyle.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      padding: const EdgeInsets.all(5),
                      textColor: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      backgroundColor: AppColors.grey,
                      text: '',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue as a Guest',
                            style: AppTextStyle.buttonText,
                          ),
                        ],
                      ),
                      onPressed: () {
                        AppDialogs.showInfoToast('Google login not implemented');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account? ',
                        style: AppTextStyle.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushRoute(const RegisterRoute());
                          viewModel.clearForm();
                        },
                        child: Text(
                          'Create Account',
                          style: AppTextStyle.titleSmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}