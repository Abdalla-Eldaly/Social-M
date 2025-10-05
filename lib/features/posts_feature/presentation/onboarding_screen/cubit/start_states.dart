enum AuthStatus {
  initial,
  loading,
  authenticated,
  guest,
  unauthenticated,
  error
}

class OnboardingState {
  final AuthStatus status;
  final String? errorMessage;

  OnboardingState({required this.status, this.errorMessage});

  factory OnboardingState.initial() => OnboardingState(status: AuthStatus.initial);
  factory OnboardingState.loading() => OnboardingState(status: AuthStatus.loading);
  factory OnboardingState.authenticated() => OnboardingState(status: AuthStatus.authenticated);
  factory OnboardingState.guest() => OnboardingState(status: AuthStatus.guest);
  factory OnboardingState.unauthenticated() => OnboardingState(status: AuthStatus.unauthenticated);
  factory OnboardingState.error(String message) =>
      OnboardingState(status: AuthStatus.error, errorMessage: message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => status.hashCode ^ errorMessage.hashCode;
}