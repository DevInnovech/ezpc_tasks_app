import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final Color color;
  final Color? borderColor;
  final VoidCallback onTap;

  const SocialButton({
    Key? key,
    this.icon,
    this.imagePath,
    required this.color,
    this.borderColor,
    required this.onTap,
  })  : assert(icon != null || imagePath != null,
            'Either icon or imagePath must be provided.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color
          shape: BoxShape.rectangle, // Rectangle shape
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : null, // Optional border
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Icon(
        icon,
        color: color, // Icon color
      );
    } else if (imagePath != null) {
      return CustomImage(path: imagePath!);
    }
    return SizedBox
        .shrink(); // In case both icon and imagePath are null, though it shouldn't happen due to assert.
  }
}
