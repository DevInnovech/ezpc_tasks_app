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
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordNotifier = ref.read(forgotPasswordProvider.notifier);
    final selectedOption =
        ModalRoute.of(context)?.settings.arguments as String?;

    ref.listen<PasswordStateModel>(forgotPasswordProvider, (previous, state) {
      final passwordState = state.passwordState;
      if (passwordState is ForgotPasswordStateError) {
        Utils.errorSnackBar(context, passwordState.message);
      } else if (passwordState is ForgotPasswordStateLoaded) {
        Utils.showSnackBar(context, passwordState.message);

        if (selectedOption == 'sms') {
          Navigator.pushNamed(
            context,
            RouteNames.verificationCodeScreen,
            arguments: true,
          );
        }
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
                                    borderSide: BorderSide(
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
                    // Handle the SMS case here
                    const CustomText(
                      text: 'Verification Code',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                    Utils.verticalSpace(12.0),
                    const CustomText(
                      text:
                          'A 6-digit code was sent to your phone number. Please enter the code to continue.',
                      fontSize: 14.0,
                    ),
                    Utils.verticalSpace(30.0),
                    // Implement your OTP input here or navigate to the OTP screen
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
                          passwordNotifier.forgotPassWord();
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
