import 'dart:async';
import 'package:banner_carousel/banner_carousel.dart';
import 'package:ezpc_tasks_app/features/home/models/slider_model.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientSliderSection extends StatefulWidget {
  const ClientSliderSection({super.key, required this.sliders});
  final List<SliderModel> sliders;

  @override
  State<ClientSliderSection> createState() => _ClientSliderSectionState();
}

class _ClientSliderSectionState extends State<ClientSliderSection> {
  late PageController controller;
  int currentPage = 0;
  @override
  void initState() {
    controller =
        PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      //autoPlay();
    });
    super.initState();
    // controller.addListener(autoPlay);
  }

  // autoPlay() {
  //   Future.delayed(const Duration(seconds: 3)).then((value) {
  //     if (currentPage < widget.sliders.length - 1) {
  //       //currentPage = controller.page!.toInt() + 1;
  //       controller.nextPage(
  //           duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  //     } else {
  //       if (controller.page!.toInt() == 1) {
  //         currentPage = controller.page!.toInt();
  //       }
  //       controller.previousPage(
  //           duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  //     }
  //   });
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BannerCarousel.fullScreen(
        height: 160.0.h,
        indicatorBottom: false,
        animation: true,
        customizedIndicators: IndicatorModel.animation(
          width: 6.0.h,
          height: 3.0.h,
          spaceBetween: 1.0,
          widthAnimation: 18.0,
        ),
        borderRadius: 20.0.r,
        activeColor: primaryColor,
        disableColor: greyColor,
        initialPage: 0,
        pageController: controller,
        customizedBanners: List.generate(
          widget.sliders.length,
          (index) => Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
              color: const Color(0xFFEAF4FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImage(
                    path: widget.sliders[index].image,
                    fit: BoxFit.cover,
                    url: null,
                  ),
                  Column(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: index.isEven
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          widget.sliders[index].title,
                          textAlign:
                              index.isEven ? TextAlign.start : TextAlign.end,
                          style: const TextStyle(
                            color: Color(0xFF051533),
                            fontSize: 18,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          /* Navigator.pushNamed(
                              context, RouteNames.serviceListScreen,
                              arguments: {
                                'title': 'Feature Services',
                                'slug': 'feature'
                              });*/
                        },
                        child: Container(
                            // width: 95.w,
                            // height: 30.h,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "See More",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
