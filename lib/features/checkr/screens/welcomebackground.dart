import 'package:ezpc_tasks_app/features/checkr/screens/candidate_screen.dart';
import 'package:flutter/material.dart';

class WelcomeBackgroundCheckScreen extends StatelessWidget {
  const WelcomeBackgroundCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .center, // Todo está centrado excepto los subtítulos
          children: [
            // Título principal
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Background Check",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Imagen principal
            Expanded(
              flex: 2, // Reduce el tamaño de la imagen
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/images/backgroundillustration.png', // Ruta de la ilustración
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Subtítulos
            const Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Alinea los textos a la izquierda
                  children: [
                    Text(
                      "A background check is required to continue using the application. It ensures a safe and reliable environment for all users.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.left, // Alineado a la izquierda
                    ),
                    SizedBox(height: 16),
                    Text(
                      "This process will be securely managed by Checkr, our trusted partner for background screening services. By proceeding, you agree to comply with Checkr's terms and conditions, ensuring a transparent and reliable verification process.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.left, // Alineado a la izquierda
                    ),
                  ],
                ),
              ),
            ),
            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Botón color morado
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CandidateFormScreen(), // Reemplaza con tu próxima pantalla
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 18, color: Colors.white), // Letras blancas
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Skip for now",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple, // Botón secundario morado
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
