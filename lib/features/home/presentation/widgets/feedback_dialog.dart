import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedBackDialog extends StatelessWidget {
  const FeedBackDialog(
      {Key? key,
      required this.image,
      required this.message,
      required this.child,
      this.height = 240.0})
      : super(key: key);
  final String image;
  final String message;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      child: SizedBox(
        width: 330.0.w,
        height: height.h,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -70.0,
              // left: 85.0.w,

              child: Container(
                // height: 138.0.h,
                // width: 138.0.w,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.2),
                ),
                child: Container(
                  // height: 90.0.h,
                  // width: 90.0.w,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                  child: SvgPicture.asset(image, height: 41.0.h, width: 46.0.w),
                ),
              ),
            ),
            Positioned.fill(
              top: 55.0.h,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Utils.verticalSpace(16),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0.sp,
                          color: const Color(0xFF162B49)),
                    ),
                    Utils.verticalSpace(10),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
