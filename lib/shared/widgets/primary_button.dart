import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.maximumSize = const Size(double.infinity, 52),
    required this.text,
    this.fontSize = 14.0,
    required this.onPressed,
    this.textColor = whiteColor,
    this.bgColor = primaryColor,
    this.minimumSize = const Size(double.infinity, 52),
    this.borderRadiusSize = 10.0,
    this.enabled = true, // Añadido enabled
    this.disabledColor =
        Colors.grey, // Color opcional para el botón deshabilitado
  });

  final VoidCallback? onPressed;
  final String text;
  final Size maximumSize;
  final Size minimumSize;
  final double fontSize;
  final double borderRadiusSize;
  final Color textColor;
  final Color bgColor;
  final bool enabled; // Añadido enabled
  final Color disabledColor; // Añadido disabledColor

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(borderRadiusSize);

    // El color del botón dependerá del estado (habilitado o deshabilitado)
    final backgroundColor = enabled ? bgColor : disabledColor;

    return ElevatedButton(
      onPressed: enabled
          ? onPressed
          : null, // Si no está habilitado, onPressed es null
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        splashFactory: NoSplash.splashFactory,
        shadowColor: WidgetStateProperty.all(transparent),
        overlayColor: WidgetStateProperty.all(transparent),
        elevation: WidgetStateProperty.all(0.0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        minimumSize: WidgetStateProperty.all(minimumSize),
        maximumSize: WidgetStateProperty.all(maximumSize),
      ),
      child: Center(
        child: Padding(
          padding: Utils.only(bottom: 0.0),
          child: CustomText(
            text: text,
            textAlign: TextAlign.center,
            color: textColor,
            fontSize: fontSize.sp,
            height: 1.5.h,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
