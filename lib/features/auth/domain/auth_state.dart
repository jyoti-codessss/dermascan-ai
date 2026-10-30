import 'package:dermascan_ai/core/errors/app_failure.dart';
import 'package:dermascan_ai/features/auth/domain/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticating extends AuthState {
  const Authenticating();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class AuthFailureState extends AuthState {
  final AppFailure failure;
  const AuthFailureState(this.failure);
}
