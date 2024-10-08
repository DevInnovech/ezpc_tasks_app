import 'package:ezpc_tasks_app/features/home/data/dashboardprovider.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_curve_shape.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form.dart';
import 'package:ezpc_tasks_app/shared/widgets/error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/heading_dialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndDrawerMenu extends ConsumerWidget {
  const EndDrawerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final profile = ref.watch(dashboardNotifierProvider);
    const image = KImages.pp;
    return SafeArea(
      child: Drawer(
        backgroundColor: blackColor,
        elevation: 0.0,
        child: ListView(
          children: [
            Padding(
              padding: Utils.symmetric(h: 10.0, v: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Utils.vSize(50.0),
                    width: Utils.vSize(50.0),
                    margin: Utils.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: Utils.borderRadius(r: 6.0),
                      child: CustomImage(
                        path: image,
                        fit: BoxFit.cover,
                        height: Utils.vSize(50.0),
                        width: Utils.vSize(50.0),
                        url: null,
                      ),
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "name",
                        color: whiteColor,
                      ),
                      CustomText(
                        text: "email",
                        fontSize: 12.0,
                        color: whiteColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DrawerItem(
              icon: KImages.di01,
              title: 'Appointment Schedule',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.scheduleScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di02,
              title: 'Profile',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.profileScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di04,
              title: 'Review',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.reviewScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di04,
              title: 'Chats',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.chatListScreen);

                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.di05,
              title: 'Change Password',
              onTap: () {
                Navigator.pushNamed(context, RouteNames.changePasswordScreen);
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            DrawerItem(
              icon: KImages.deleteAccount,
              title: 'Delete Account',
              onTap: () {
                deleteDialog(context, ref);
              },
            ),
            DrawerItem(
              icon: KImages.di10,
              isBorder: false,
              title: 'Logout',
              onTap: () {
                showLogoutBottomSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutBottomSheet(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    showModalBottomSheet(
      backgroundColor: transparent,
      context: context,
      useSafeArea: true,
      builder: (context) => CustomPaint(
        size: Size(size.width, 232.0),
        painter: CustomCurveShape(),
        willChange: true,
        child: Container(
          padding: Utils.symmetric(v: 0.0),
          height: Utils.vSize(232.0),
          child: Column(
            children: [
              Utils.verticalSpace(5.0),
              const CustomImage(
                path: KImages.lineIcon,
                color: whiteColor,
                url: null,
              ),
              Utils.verticalSpace(16.0),
              const CustomText(
                text: 'LOGOUT',
                fontWeight: FontWeight.w700,
                color: redColor,
                fontSize: 24.0,
              ),
              Container(
                height: 2.0,
                margin: Utils.symmetric(h: 0.0, v: 16.0),
                color: grayColor.withOpacity(0.1),
              ),
              const CustomText(
                text: 'Are you sure you want to Logout?',
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 18.0,
              ),
              Utils.verticalSpace(24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PrimaryButton(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    bgColor: blackColor,
                    fontSize: 16.0,
                    minimumSize: Size(Utils.hSize(150.0), Utils.vSize(52.0)),
                  ),
                  PrimaryButton(
                    text: 'Logout',
                    onPressed: () {
                      // Replace with Riverpod-based logout logic
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.authenticationScreen,
                        (route) => false,
                      );
                    },
                    bgColor: redColor,
                    textColor: whiteColor,
                    fontSize: 16.0,
                    minimumSize: Size(Utils.hSize(150.0), Utils.vSize(52.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final showPassword = StateProvider<bool>((ref) => false);

    Utils.showCustomDialog(
      context,
      child: Padding(
        padding: Utils.symmetric(v: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeading(
              title: 'Account Delete',
              onTap: () {
                Navigator.of(context).pop();
                passwordController.clear();
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final isPasswordVisible = ref.watch(showPassword);

                return CustomForm(
                  label: 'Current Password',
                  bottomSpace: 24.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Utils.borderRadius(),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Utils.borderRadius(),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: Utils.borderRadius(),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          hintText: 'Current Password',
                          filled: true,
                          fillColor: scaffoldBgColor,
                          suffixIcon: IconButton(
                            splashRadius: 16.0,
                            onPressed: () {
                              ref
                                  .read(showPassword.notifier)
                                  .update((state) => !state);
                            },
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: grayColor,
                            ),
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                      ),
                      if (passwordController.text.isEmpty)
                        const ErrorText(text: 'Password cannot be empty'),
                    ],
                  ),
                );
              },
            ),
            PrimaryButton(
              text: 'Delete Account',
              onPressed: () {
                Utils.closeKeyBoard(context);
                // Add your delete account logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isBorder = true,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool isBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(left: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: Utils.symmetric(h: 0.0, v: 12.0),
          margin: Utils.only(bottom: 6.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isBorder ? whiteColor.withOpacity(0.2) : transparent,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImage(
                path: icon,
                url: null,
              ),
              Utils.horizontalSpace(12.0),
              CustomText(
                text: title,
                color: whiteColor,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
