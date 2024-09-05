import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';

class AccountTypeSelector extends StatelessWidget {
  final String title;
  final String description;
  final Widget iconOrImage; // Ahora acepta cualquier widget
  final bool isSelected;
  final VoidCallback onTap;

  const AccountTypeSelector({
    required this.title,
    required this.description,
    required this.iconOrImage, // Renombrado a `iconOrImage`
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: BoxDecoration(
            color: TextFieldgraycolor,
            borderRadius: BorderRadius.circular(12.0),
            border: isSelected
                ? Border.all(color: primaryColor, width: 2.0)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconOrImage, // Ahora puede ser un ícono o una imagen
              Utils.horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: title,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 4.0),
                    CustomText(
                      text: description,
                      fontSize: 14.0,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}