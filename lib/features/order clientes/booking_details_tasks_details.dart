import 'package:ezpc_tasks_app/features/home/models/provider_model.dart';
import 'package:ezpc_tasks_app/features/order%20clientes/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:ezpc_tasks_app/shared/widgets/purchase_info_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:flutter_svg/flutter_svg.dart";

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key, required this.order});

  final OrderDetailsDto order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Order Details"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: LoadedWidget(data: order),
      ),
    );
  }
}

class LoadedWidget extends StatelessWidget {
  const LoadedWidget({super.key, required this.data});

  final OrderDetailsDto data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.verticalSpace(6),
          ProviderInfo(
            provider: ProviderModel(
              name: data.providerName,
              email: data.providerEmail,
              phone: data.providerPhone,
              image: data.providerImageUrl,
              id: 0,
              rating: data.rating,
              reviews: 0,
            ),
          ),
          Utils.verticalSpace(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalles del Servicio',
                style: TextStyle(
                  color: Color(0xFF051533),
                  fontSize: 18,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.67,
                ),
              ),
              Utils.verticalSpace(8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(children: [
                  Text(
                    data.taskName,
                    style: const TextStyle(
                      color: Color(0xFF535769),
                      fontSize: 18,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.67,
                    ),
                  ),
                  Utils.verticalSpace(8),
                  const Divider(),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Tarifa del Paquete',
                    trailText: data.price.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Descuento',
                    trailText: data.discount.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  Divider(
                    color: blackColor.withOpacity(0.1),
                  ),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Sub Total',
                    trailText: (data.price - data.discount).toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  PurchaseInfoText(
                    text: 'Impuestos',
                    trailText: data.tax.toStringAsFixed(2),
                  ),
                  Utils.verticalSpace(8),
                  Divider(
                    color: blackColor.withOpacity(0.1),
                  ),
                  PurchaseInfoText(
                    text: 'Total',
                    trailText: data.total.toStringAsFixed(2),
                    textColor: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  Utils.verticalSpace(16),
                  PurchaseInfoStatus(
                    text: 'Estado de Pago',
                    trailText: data.status,
                  ),
                ]),
              ),
              Utils.verticalSpace(20),
              const Text(
                'Estado de la Orden',
                style: TextStyle(
                  color: Color(0xFF051533),
                  fontSize: 18,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.67,
                ),
              ),
              Utils.verticalSpace(8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: PurchaseInfoStatus(
                  text: 'Estado de la Orden',
                  trailText: data.status,
                ),
              ),
              Utils.verticalSpace(20),
              // Botón de Seguimiento
              PrimaryButton(
                text: "Tracking",
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.providerTracking,
                      arguments: data);
                },
              ),
              Utils.verticalSpace(10),
              // Botón para Cancelar la Orden
              PrimaryButton(
                text: "Cancelar",
                onPressed: () {
                  Utils.showSnackBar(context, 'La orden ha sido cancelada');
                },
                bgColor: Colors.red,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ProviderInfo extends StatelessWidget {
  const ProviderInfo({
    super.key,
    required this.provider,
  });

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles del Vendedor',
          style: TextStyle(
            color: Color(0xFF051533),
            fontSize: 18,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w600,
            height: 1.67,
          ),
        ),
        Utils.verticalSpace(8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(children: [
            provider.image != null &&
                    provider.image != 'N/A' &&
                    provider.image != ''
                ? SizedBox(
                    height: 94.h,
                    width: 94.w,
                    child: CustomImage(
                      path: provider.image,
                      fit: BoxFit.cover,
                      url: null,
                    ))
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
            Utils.horizontalSpace(10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(
                    color: Color(0xFF051533),
                    fontSize: 18,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Utils.verticalSpace(8),
                Row(
                  children: [
                    //phone

                    SvgPicture.asset(KImages.call),

                    Utils.horizontalSpace(4),
                    Text(
                      provider.phone ?? '',
                      style: const TextStyle(
                        color: Color(0xFF535769),
                        fontSize: 12,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ],
                ),
                Utils.verticalSpace(8),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SvgPicture.asset(KImages.booking),
                    ),
                    Utils.horizontalSpace(4),
                    Text(
                      provider.email ?? '',
                      style: const TextStyle(
                        color: Color(0xFF535769),
                        fontSize: 12,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ],
                ),
              ],
            ))
          ]),
        )
      ],
    );
  }
}
