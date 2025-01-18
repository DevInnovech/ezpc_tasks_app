import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordStateModel {
  final String email;
  final String phoneNumber;
  final ForgotPasswordState passwordState;

  PasswordStateModel({
    required this.email,
    required this.phoneNumber,
    required this.passwordState,
  });
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
          email: '',
          phoneNumber: '',
          passwordState: ForgotPasswordStateInitial(),
        ));

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Actualiza el correo electrónico
  void changeEmail(String email) {
    state = PasswordStateModel(
      email: email,
      phoneNumber: state.phoneNumber,
      passwordState: state.passwordState,
    );
  }

  /// Actualiza el número de teléfono
  void changePhoneNumber(String phoneNumber) {
    state = PasswordStateModel(
      email: state.email,
      phoneNumber: phoneNumber,
      passwordState: state.passwordState,
    );
  }

  Future<void> forgotPassWord(String method) async {
    // Validaciones
    if (method == 'email' && state.email.isEmpty) {
      state = PasswordStateModel(
        email: state.email,
        phoneNumber: state.phoneNumber,
        passwordState: ForgotPasswordFormValidateError({
          'email': ['Email cannot be empty'],
        }),
      );
      return;
    }

    if (method == 'sms' && state.phoneNumber.isEmpty) {
      state = PasswordStateModel(
        email: state.email,
        phoneNumber: state.phoneNumber,
        passwordState: ForgotPasswordFormValidateError({
          'phoneNumber': ['Phone number cannot be empty'],
        }),
      );
      return;
    }

    state = PasswordStateModel(
      email: state.email,
      phoneNumber: state.phoneNumber,
      passwordState: ForgotPasswordStateLoading(),
    );

    try {
      if (method == 'email') {
        // Enviar correo de restablecimiento de contraseña
        try {
          await _auth.sendPasswordResetEmail(email: state.email);
          // Si el correo se envió correctamente
          state = PasswordStateModel(
            email: state.email,
            phoneNumber: state.phoneNumber,
            passwordState: ForgotPasswordStateLoaded(
              'Reset link sent successfully to ${state.email}',
            ),
          );
        } on FirebaseAuthException catch (e) {
          // Manejar errores específicos de Firebase
          state = PasswordStateModel(
            email: state.email,
            phoneNumber: state.phoneNumber,
            passwordState: ForgotPasswordStateError(
              'Failed to send reset link: ${e.message}',
            ),
          );
        } catch (e) {
          // Manejar otros errores
          state = PasswordStateModel(
            email: state.email,
            phoneNumber: state.phoneNumber,
            passwordState: ForgotPasswordStateError(
              'An unexpected error occurred. Please try again.',
            ),
          );
        }
      } else if (method == 'sms') {
        // Enviar código SMS
        await _auth.verifyPhoneNumber(
          phoneNumber: state.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            // Auto-verificación completada
            state = PasswordStateModel(
              email: state.email,
              phoneNumber: state.phoneNumber,
              passwordState: ForgotPasswordStateLoaded(
                'Phone number verified successfully!',
              ),
            );
          },
          verificationFailed: (FirebaseAuthException e) {
            // Manejar errores de verificación
            state = PasswordStateModel(
              email: state.email,
              phoneNumber: state.phoneNumber,
              passwordState: ForgotPasswordStateError(
                'Failed to verify phone number: ${e.message}',
              ),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            // Código enviado correctamente
            state = PasswordStateModel(
              email: state.email,
              phoneNumber: state.phoneNumber,
              passwordState: ForgotPasswordStateLoaded(
                'Verification code sent to ${state.phoneNumber}',
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Tiempo de espera agotado
            state = PasswordStateModel(
              email: state.email,
              phoneNumber: state.phoneNumber,
              passwordState: ForgotPasswordStateError(
                'Timeout while sending the verification code.',
              ),
            );
          },
        );
      }
    } catch (e) {
      // Manejar cualquier error inesperado
      state = PasswordStateModel(
        email: state.email,
        phoneNumber: state.phoneNumber,
        passwordState: ForgotPasswordStateError(
          'Failed to send ${method == 'email' ? 'reset link' : 'verification code'}. Please try again.',
        ),
      );
    }
  }
}
