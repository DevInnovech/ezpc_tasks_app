import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';
import 'primary_button.dart';

class PleaseSigninWidget extends StatelessWidget {
  const PleaseSigninWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImage(
                path: KImages.login,
                height: MediaQuery.of(context).size.height * 0.4,
                url: null,
              ),
              Utils.verticalSpace(10),
              const Text(
                "Your are not logged in, please login first!",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                // text: Language.login.capitalizeByWord(),
                text: "Got to Login",
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RouteNames.authenticationScreen, (v) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
