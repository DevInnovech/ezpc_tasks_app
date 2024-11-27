import 'package:ezpc_tasks_app/features/referral/presentation/widgets/referral_list.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo de color en la parte superior
          Container(
            height: double.infinity, // Ocupa toda la altura
            color: primaryColor,
          ),
          // Contenido principal con bordes redondeados en la parte superior
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget de AppBar personalizado
              buildCustomAppBar(context, "Referrals"),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: const Column(
                    children: [
                      // Encabezado de bonos de referidos

                      // Lista de referidos
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ReferralList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget del AppBar personalizado
}

// Widget del AppBar personalizado
Widget buildCustomAppBar(BuildContext context, String title) {
  return Container(
    padding:
        const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0, bottom: 10.0),
    color: Colors.transparent,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Botón de retroceso alineado a la izquierda
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // Título centrado en la pantalla
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
