import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordStateModel {
  final String email;
  final ForgotPasswordState passwordState;

  PasswordStateModel({required this.email, required this.passwordState});
}

abstract class ForgotPasswordState {}

class ForgotPasswordStateInitial extends ForgotPasswordState {}

class ForgotPasswordStateLoading extends ForgotPasswordState {}

class ForgotPasswordStateLoaded extends ForgotPasswordState {
  final String message;

  ForgotPasswordStateLoaded(this.message);
}

class ForgotPasswordStateError extends ForgotPasswordState {
  final String message;

  ForgotPasswordStateError(this.message);
}

class ForgotPasswordFormValidateError extends ForgotPasswordState {
  final Map<String, List<String>> errors;

  ForgotPasswordFormValidateError(this.errors);
}

class ForgotPasswordNotifier extends StateNotifier<PasswordStateModel> {
  ForgotPasswordNotifier()
      : super(PasswordStateModel(
            email: '', passwordState: ForgotPasswordStateInitial()));

  void changeEmail(String email) {
    state =
        PasswordStateModel(email: email, passwordState: state.passwordState);
  }

  void forgotPassWord() async {
    if (state.email.isEmpty) {
      state = PasswordStateModel(
          email: state.email,
          passwordState: ForgotPasswordFormValidateError({
            'email': ['Email cannot be empty'],
          }));
      return;
    }

    state = PasswordStateModel(
      email: state.email,
      passwordState: ForgotPasswordStateLoading(),
    );

    try {
      // Simulate a network request
      await Future.delayed(const Duration(seconds: 2));
      state = PasswordStateModel(
        email: state.email,
        passwordState:
            ForgotPasswordStateLoaded('Reset code sent to ${state.email}'),
      );
    } catch (e) {
      state = PasswordStateModel(
        email: state.email,
        passwordState: ForgotPasswordStateError('Failed to send reset code'),
      );
    }
  }
}
