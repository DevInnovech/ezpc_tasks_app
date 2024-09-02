import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isShowBackButton;
  final double textSize;
  final FontWeight fontWeight;
  final Color textColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isShowBackButton = true,
    this.textSize = 22.0,
    this.fontWeight = FontWeight.w700,
    this.textColor = blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 20.0), // Ajusta el padding superior
        child: Stack(
          children: [
            if (isShowBackButton)
              const Positioned(
                left: 16.0,
                top: 0,
                bottom: 0,
                child: BackButtonWidget(),
              ),
            Center(
              child: CustomText(
                text: title,
                fontSize: textSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        height: 36.0, // Altura ajustada para ser simétrica
        width: 36.0, // Anchura igual que la altura para simetría
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), // Borde redondeado
          border: Border.all(color: grayColor.withOpacity(0.5)),
          color: Colors.white,
        ),
        child: const Icon(Icons.arrow_back_ios,
            size: 18.0), // Ícono ligeramente más pequeño para ajustarse mejor
      ),
    );
  }
}
