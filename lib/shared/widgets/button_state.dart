import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class EstadoButton extends StatelessWidget {
  const EstadoButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.isActive = false,
    this.normalColor = primaryColor,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.normalBorderColor = primaryColor,
    this.activeBorderColor = Colors.green,
    this.normalShadowColor = primaryColor,
    this.activeShadowColor = Colors.green,
    this.inactiveShadowColor = Colors.black12,
    this.textColor = Colors.black,
    this.borderRadius = 15.0,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final bool enabled;
  final bool isActive;
  final Color normalColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color normalBorderColor;
  final Color activeBorderColor;
  final Color normalShadowColor;
  final Color activeShadowColor;
  final Color inactiveShadowColor;
  final Color textColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isActive ? activeBorderColor : normalBorderColor;

    // Mantiene el formato de la sombra, pero cambia solo el color según el estado
    final Color shadowColor = enabled
        ? (isActive ? activeShadowColor : normalShadowColor)
        : inactiveShadowColor;

    final BoxShadow shadow = BoxShadow(
      color: shadowColor,
      blurRadius: 1.0,
      spreadRadius: 0.1,
      offset: const Offset(0, 0),
    );

    final Color currentTextColor = enabled ? textColor : inactiveColor;
    final Color currentIconColor =
        enabled ? (isActive ? activeColor : normalColor) : inactiveColor;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: enabled ? borderColor : inactiveColor,
            width: 1.5,
          ),
          boxShadow: [shadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: currentIconColor,
              size: 24.0,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: currentTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
