import 'package:ezpc_tasks_app/features/home/models/service_item.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:ezpc_tasks_app/shared/widgets/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientSingleCategoryView extends StatelessWidget {
  const ClientSingleCategoryView({Key? key, required this.item})
      : super(key: key);
  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /* Navigator.pushNamed(
          context,
          RouteNames.detailsScreen,
          arguments: item.slug,
        );*/
      },
      child: Container(
        width: 164.0.w,
        // height: 264.0.h,
        margin: const EdgeInsets.only(right: 0),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 1.0),
          borderRadius: BorderRadius.circular(8.0.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 170.0.w,
              height: 98.0.h,
              margin: EdgeInsets.only(bottom: 10.0.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImage(
                  path: item.image,
                  //aregla para imagenes realews
                  /*  RemoteUrls.imageUrl(),*/
                  fit: BoxFit.cover,
                  // width: 170.0.w,
                  height: 107.0.h,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SvgPicture.asset(
                            KImages.priceTag,
                            height: 14.h,
                            width: 14.h,
                          ),
                        ),
                        Utils.horizontalSpace(4),
                        Text(
                          item.price.toString(),
                          style: KTextStyle.workSans(
                            fs: 14.0,
                            c: primaryColor,
                            fw: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          KImages.starSolid,
                          height: 10.h,
                          width: 10.h,
                        ),
                        Utils.horizontalSpace(4),
                        Text(
                          '${item.averageRating}(${item.totalReview})',
                          style: const TextStyle(
                            color: Color(0xFF535769),
                            fontSize: 12,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Utils.verticalSpace(8),
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KTextStyle.workSans(
                      fs: 14.0,
                      c: blackColor,
                      fw: FontWeight.w700,
                    )),
                SizedBox(height: 9.0.h),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      //  backgroundImage:,
                      /* NetworkImage(
                          RemoteUrls.imageUrl(item.provider!.image)),*/
                    ),
                    Utils.horizontalSpace(8),
                    StreamBuilder<Object>(
                        stream: null,
                        builder: (context, snapshot) {
                          return Expanded(
                            child: Text(
                              'by ${item.provider!.name}',
                              maxLines: 1,
                              style: KTextStyle.workSans(
                                  fs: 12.0, c: blackColor, fw: FontWeight.w400),
                            ),
                          );
                        }),
                  ],
                ),
                Utils.verticalSpace(8),
                PrimaryButton(
                  text: 'Book Now',
                  onPressed: () {
                    // Convierte el ServiceItem al ServiceModel antes de navegar
                    final ServiceModel serviceModel = toServiceModel(item);

                    Navigator.pushNamed(
                      context,
                      RouteNames.primierServiceScreen,
                      arguments: {
                        'service': serviceModel, // El servicio convertido
                        'categories': categories, // Las categorías disponibles
                      },
                    );
                  },
                  fontSize: 14,
                  maximumSize: const Size(double.infinity, 32),
                  minimumSize: const Size(double.infinity, 32),
                  borderRadiusSize: 5.0,
                ),

                // Utils.verticalSpace(4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

ServiceModel toServiceModel(ServiceItem item) {
  return ServiceModel(
    id: item.id.toString(),
    name: item.name,
    slug: item.slug,
    price: item.price.toString(),
    categoryId: item.categoryId,
    subCategoryId: item.category!.subCategories.isNotEmpty
        ? item.category!.subCategories.first.id
        : '', // Ajusta según lo que necesites
    details: item.details,
    image: item.image,
    packageFeature: [],
    benefits: [],
    whatYouWillProvide: [],
    licenseDocument: '',
    workingDays: [],
    workingHours: [],
    specialDays: [],
    status: 'Active', provider: item.provider, // O ajusta según tu lógica
  );
}
