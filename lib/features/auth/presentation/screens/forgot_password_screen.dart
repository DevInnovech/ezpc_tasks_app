import 'package:ezpc_tasks_app/features/auth/presentation/screens/greates_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/auth/state/statepassword.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_sliver_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, PasswordStateModel>(
  (ref) => ForgotPasswordNotifier(),
);

class ForgotPasswordScreen extends ConsumerWidget {
  final String selectedOption;
  const ForgotPasswordScreen({super.key, required this.selectedOption});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordNotifier = ref.read(forgotPasswordProvider.notifier);

    ref.listen<PasswordStateModel>(forgotPasswordProvider, (previous, state) {
      final passwordState = state.passwordState;
      if (passwordState is ForgotPasswordStateError) {
        Utils.errorSnackBar(context, passwordState.message);
      } else if (passwordState is ForgotPasswordStateLoaded) {
        Utils.showSnackBar(context, passwordState.message);

        // Navegación a la pantalla de felicitaciones
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (newContext) => VerificationCompletedScreen(
              title: 'Congratulations! 🎉',
              subtitle: selectedOption == 'sms'
                  ? 'Verification code sent successfully to your phone.'
                  : 'Reset link sent successfully to your email.',
              onContinue: () {
                if (selectedOption == null) {
                  ScaffoldMessenger.of(newContext).showSnackBar(
                    const SnackBar(
                      content: Text('No option selected. Please try again.'),
                    ),
                  );
                  return;
                }

                // Acción según la opción seleccionada
                if (selectedOption == 'email') {
                  Navigator.pushNamed(
                      newContext, RouteNames.authenticationScreen);
                } else if (selectedOption == 'sms') {
                  Navigator.pushNamed(
                      newContext, RouteNames.authenticationScreen);
                }
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(title: ''),
          SliverPadding(
            padding: Utils.symmetric(),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  CustomImage(
                    path: KImages.lockIcon,
                    height: Utils.vSize(280.0),
                    color: primaryColor,
                    url: null,
                  ),
                  if (selectedOption == 'email') ...[
                    const CustomText(
                      text: 'Email Address',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                    Utils.verticalSpace(12.0),
                    const CustomText(
                      text:
                          'Don’t worry! It happens. Please enter the email address associated with your account.',
                      fontSize: 14.0,
                    ),
                    Utils.verticalSpace(30.0),
                    Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(forgotPasswordProvider);
                        final passwordState = state.passwordState;
                        return CustomForm(
                          label: 'Email Address',
                          bottomSpace: 30.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                onChanged: (String text) =>
                                    passwordNotifier.changeEmail(text),
                                decoration: InputDecoration(
                                  hintText: 'Your email address',
                                  filled: true,
                                  fillColor: TextFieldgraycolor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: primaryColor, width: 2.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 12.0),
                                ),
                                initialValue: state.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              if (passwordState
                                  is ForgotPasswordFormValidateError) ...[
                                if (passwordState.errors['email']?.isNotEmpty ??
                                    false)
                                  ErrorText(
                                      text:
                                          passwordState.errors['email']!.first),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (selectedOption == 'sms') ...[
                    const CustomText(
                      text: 'Phone Number',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                    Utils.verticalSpace(12.0),
                    const CustomText(
                      text:
                          'Enter your phone number to receive a 6-digit verification code.',
                      fontSize: 14.0,
                    ),
                    Utils.verticalSpace(30.0),
                    Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(forgotPasswordProvider);
                        final passwordState = state.passwordState;
                        return CustomForm(
                          label: 'Phone Number',
                          bottomSpace: 30.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                onChanged: (String text) =>
                                    passwordNotifier.changePhoneNumber(text),
                                decoration: InputDecoration(
                                  hintText: '+1 234 567 890',
                                  filled: true,
                                  fillColor: TextFieldgraycolor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: primaryColor, width: 2.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 12.0),
                                ),
                                initialValue: state.phoneNumber,
                                keyboardType: TextInputType.phone,
                              ),
                              if (passwordState
                                  is ForgotPasswordFormValidateError) ...[
                                if (passwordState
                                        .errors['phoneNumber']?.isNotEmpty ??
                                    false)
                                  ErrorText(
                                      text: passwordState
                                          .errors['phoneNumber']!.first),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(forgotPasswordProvider);
                      final passwordState = state.passwordState;

                      if (passwordState is ForgotPasswordStateLoading) {
                        return const LoadingWidget();
                      }

                      return PrimaryButton(
                        text: selectedOption == 'email'
                            ? 'Send Email'
                            : 'Send SMS',
                        onPressed: () {
                          Utils.closeKeyBoard(context);
                          passwordNotifier.forgotPassWord(selectedOption!);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
