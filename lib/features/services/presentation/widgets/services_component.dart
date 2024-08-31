import 'package:ezpc_tasks_app/features/services/models/services_model.dart';
import 'package:ezpc_tasks_app/features/services/presentation/widgets/service_delete_dialog.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:ezpc_tasks_app/features/services/models/adding_model.dart';

class ServiceComponent extends StatelessWidget {
  const ServiceComponent({Key? key, required this.service}) : super(key: key);
  final ServiceProductStateModel service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: Utils.symmetric(v: 12.0),
      padding: Utils.symmetric(h: 10.0, v: 16.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: Utils.borderRadius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Utils.vSize(150.0),
            width: double.infinity,
            child: ClipRRect(
              borderRadius: Utils.borderRadius(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImage(path: service.image, fit: BoxFit.cover),
                  Positioned.fill(
                    child: Padding(
                      padding: Utils.only(top: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Utils.horizontalSpace(10.0),
                          deleteEditButton(
                              KImages.trashIcon,
                              () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => ServiceDeleteDialog(
                                      onTap: () => {}, // delete logic
                                    ),
                                  ),
                              redColor),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Utils.getBgColor(service.status.toString()),
                        borderRadius: Utils.borderRadius(r: 20.0),
                      ),
                      child: Padding(
                        padding:
                            Utils.symmetric(h: 12.0, v: 8.0).copyWith(top: 4.0),
                        child: CustomText(
                          text: service.status,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Utils.verticalSpace(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 1.0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0), // Adjust the padding as needed
                  decoration: BoxDecoration(
                    color: bluecontras.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(
                        12.0), // Adjust the border radius for rounded corners
                  ),
                  child: CustomText(
                    text: service.categoryId,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize:
                        12.0, // Adjust font size to match the compact look
                  ),
                ),
              ),
              CustomText(
                text: Utils.formatDate('2024-12-25'), // Mocked date for demo
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          Utils.verticalSpace(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Utils.hSize(240.0),
                  maxHeight: Utils.vSize(70.0),
                ),
                child: CustomText(
                  text: service.subCategoryId,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  maxLine: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const CustomImage(path: KImages.tagIcon),
                  Utils.horizontalSpace(4.0),
                  FittedBox(
                    child: CustomText(
                      text: '\$${service.price}',
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              )
            ],
          ),
          Utils.verticalSpace(14.0),
          PrimaryButton(
            text: 'View Details',
            onPressed: () => Navigator.pushNamed(
              context,
              RouteNames.serviceDetailsScreen,
              arguments: service.id, // Pass the ID instead of slug
            ),
          ),
        ],
      ),
    );
  }

  Widget deleteEditButton(String icon, VoidCallback onTap, Color bgColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Utils.all(value: 6.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: Utils.borderRadius(r: 5.0),
        ),
        child: CustomImage(path: icon),
      ),
    );
  }
}
