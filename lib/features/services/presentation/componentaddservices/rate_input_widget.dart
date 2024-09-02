import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PriceInputWidget extends StatelessWidget {
  const PriceInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: '20.00',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Color(0xFF8D8D8D),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder:
                        InputBorder.none, // Eliminar borde cuando está enfocado
                    enabledBorder: InputBorder
                        .none, // Eliminar borde cuando está habilitado
                    errorBorder:
                        InputBorder.none, // Eliminar borde en caso de error
                    disabledBorder: InputBorder
                        .none, // Eliminar borde cuando está deshabilitado
                    isDense: true,
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
