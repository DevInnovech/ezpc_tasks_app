import 'package:ezpc_tasks_app/features/home/data/client_provider.dart';
import 'package:ezpc_tasks_app/features/home/models/userdash_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/features/home/data/client_data_model.dart';

class ClientHomeHeader extends ConsumerWidget {
  const ClientHomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 178.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            color: primaryColor,
            height: 178.h,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ref.watch(clientDashBoardProfileProvider).when(
                  data: (UserDashBoardModel userDashboardModel) {
                    final user = userDashboardModel.user;
                    return Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 0.50,
                                color: Color(0xFFEAF4FF),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              /* Navigator.pushNamed(
                                  context, RouteNames.editProfile);*/
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const CustomImage(
                                path: KImages.pp,
                                // CUANDO FUNCIONE CON FIREBASE ESAS ES LA PREGUNTA  AHCER
                                /* user.image != null
                                    ? RemoteUrls.imageUrl(user.image!)
                                    : KImages
                                        .appLayer, */ // Imagen por defecto si es nulo
                                fit: BoxFit.cover, url: null,
                              ),
                            ),
                          ),
                        ),
                        Utils.horizontalSpace(10),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Good Morning!',
                                style: TextStyle(
                                  color: Color(0xFFEAF4FF),
                                  fontSize: 14,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w500,
                                  height: 1.57,
                                ),
                              ),
                              Text(
                                user.name, // Asegurando que el nombre está disponible
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                //aqui poner un if con los tipo de cuenta

                                "Role: Cliente", // Asegurando que el nombre está disponible
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                        Utils.horizontalSpace(10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                //suporte
                              },
                              child: Container(
                                height: Utils.vSize(50.0),
                                width: Utils.vSize(50.0),
                                margin: Utils.only(right: 10.0),
                                child: ClipRRect(
                                  borderRadius: Utils.borderRadius(r: 6.0),
                                  child: const CustomImage(
                                    path: KImages.supportIcon,
                                    fit: BoxFit.contain, url: null,
                                    //height: 50,
                                    // width: 50,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
          ),
          Positioned(
            bottom: -25,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  /* Navigator.pushNamed(context, RouteNames.searchServices);*/
                },
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 40,
                        offset: Offset(0, 2),
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: ListTile(
                    //  leading: SvgPicture.asset(KImages.searchIcon),
                    horizontalTitleGap: 10,
                    minLeadingWidth: 0,
                    title: const Text(
                      'Search Services or Providers',
                      style: TextStyle(
                        color: Color(0xFF686873),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        /*   Navigator.pushNamed(context, RouteNames.filterScreen);*/
                      },
                      child: SvgPicture.asset(KImages.filterMenu),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
