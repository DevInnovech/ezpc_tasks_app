import 'package:flutter/material.dart';

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  final Color? titleColor;
  final Color checkColor;

  const CustomCheckboxListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.titleColor,
    this.activeColor = Colors.blue, // Valor predeterminado
    this.checkColor = Colors.white, // Valor predeterminado
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Transform.translate(
        offset: const Offset(
            -10, 0), // Ajustar el espacio entre el checkbox y el texto
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: titleColor ??
                Colors.black, // Usar el color opcional si está definido
          ),
        ),
      ),
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity:
          ListTileControlAffinity.leading, // Checkbox a la izquierda
      activeColor: activeColor, // Color del checkbox cuando está activo
      checkColor: checkColor, // Color del icono de check
      contentPadding:
          EdgeInsets.zero, // Eliminar padding para acercar el texto al checkbox
      visualDensity: VisualDensity
          .compact, // Ajustar la densidad visual para acercar el texto al checkbox
    );
  }
}
