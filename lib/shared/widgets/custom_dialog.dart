import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.icon,
    required this.child,
    this.height = 0.0,
  });

  final String icon;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      child: SizedBox(
        width: Utils.hSize(size.width),
        height: Utils.vSize(height),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                left: 0.0,
                right: 0.0,
                top: -82.0,
                child: CustomImage(
                  path: KImages.dialogIcon,
                  width: Utils.hSize(164.0),
                  height: Utils.vSize(164.0),
                  url: null,
                )),
            Positioned(
                left: 0.0,
                right: 0.0,
                top: -30.0,
                child: CustomImage(
                  path: icon,
                  url: null,
                )),
            Positioned.fill(
              top: Utils.vSize(100.0),
              child: child,
            )
            // Positioned(
            //   top: Utils.vPadding(size: -30.0),
            //   left: Utils.hPadding(size: 85.0),
            //   child: Container(
            //     width: Utils.hSize(120.0),
            //     height: Utils.vSize(100.0),
            //     alignment: Alignment.center,
            //     decoration: BoxDecoration(
            //       border: Border.all(width: 6.0, color: whiteColor),
            //       shape: BoxShape.circle,
            //       color: primaryColor,
            //     ),
            //     child: CustomImage(
            //       path: KImages.dialogIcon,
            //       width: Utils.hSize(40.0),
            //       height: Utils.vSize(40.0),
            //     ),
            //   ),
            // ),
            // Positioned.fill(
            //   top: Utils.hSize(60.0),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 0.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Utils.vSpace(16.0),
            //         const CustomText(
            //           text: 'Are you sure',
            //           fontWeight: FontWeight.w700,
            //           fontSize: 30.0,
            //           color: blueGrayColor,
            //         ),
            //         Utils.vSpace(6.0),
            //         const CustomText(
            //           text: 'you want to remove this item?',
            //           fontWeight: FontWeight.w600,
            //           fontSize: 16.0,
            //           color: blueGrayColor,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Positioned.fill(
            //   top: Utils.hSize(size.height * 0.16),
            //   child: BlocListener<WishlistCubit, WishlistState>(
            //     listener: (context, state) {
            //       if (state is WishlistLoading) {
            //         Utils.loadingDialog(context);
            //       } else {
            //         Utils.closeDialog(context);
            //         Navigator.pop(context);
            //         if (state is WishlistError) {
            //           Utils.errorSnackBar(context, state.message);
            //         }
            //         if (state is WishListStateSuccess) {
            //           Utils.showSnackBar(context, state.message);
            //           //context.read<WishlistCubit>().getWistItems();
            //         }
            //       }
            //     },
            //     child: Row(
            //       mainAxisSize: MainAxisSize.max,
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         PrimaryButton(
            //           text: 'Cancel',
            //           onPressed: () => Navigator.of(context).pop(),
            //           bgColor: blueGrayColor,
            //           borderRadiusSize: 4.0,
            //           textColor: whiteColor,
            //           minimumSize: Size(Utils.hSize(120.0), Utils.vSize(50.0)),
            //         ),
            //         PrimaryButton(
            //           text: 'Remove',
            //           onPressed: () {
            //             print("id: $id");
            //             context.read<WishlistCubit>().deleteWishItem(id);
            //           },
            //           bgColor: primaryColor,
            //           borderRadiusSize: 4.0,
            //           textColor: whiteColor,
            //           minimumSize: Size(Utils.hSize(120.0), Utils.vSize(50.0)),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Column buildColumn() {
    return const Column(
      children: [
        CustomText(
          text: 'Are you Publish\nthis Servic',
          fontSize: 18.0,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
