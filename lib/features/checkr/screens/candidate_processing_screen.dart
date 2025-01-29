import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/routes.dart';

class CandidateProcessingScreen extends StatefulWidget {
  final String candidateId;
  final String email;

  const CandidateProcessingScreen({
    super.key,
    required this.candidateId,
    required this.email,
  });

  @override
  _CandidateProcessingScreenState createState() =>
      _CandidateProcessingScreenState();
}

class _CandidateProcessingScreenState extends State<CandidateProcessingScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBackgroundCheckStatus() {
    return FirebaseFirestore.instance
        .collection('background_checks')
        .doc(widget.candidateId)
        .snapshots();
  }

  void navigateToAuthentication() {
    Navigator.pushReplacementNamed(context, RouteNames.authenticationScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 🔥 Elimina el botón de atrás
        title: const Text(
          "Background Check Status",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A0DAD), // 🎨 Morado correcto
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getBackgroundCheckStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("Candidate data not found.",
                    style: TextStyle(fontSize: 16, color: Colors.red)));
          }

          final data = snapshot.data!.data()!;
          final status = data['status'] ?? 'Unknown';
          final result = data['result'] ?? 'Unknown';

          // ✅ Background check aprobado (clear)
          if (status == 'complete' && result == 'clear') {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Imagen de éxito
                  Image.asset(
                    'assets/images/Success.png',
                    height: 200,
                  ),
                  const SizedBox(height: 30),

                  // 🎉 Mensaje de éxito
                  const Text(
                    "Congratulations!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 📩 Mensaje de aprobación
                  const Text(
                    "Your background check has been completed successfully. "
                    "We are now ready to proceed!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Botón de "Continue"
                  ElevatedButton(
                    onPressed: navigateToAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF6A0DAD), // 🎨 Morado correcto
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // ❌ Background check en "consider"
          if (status == 'complete' && result == 'consider') {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ❌ Imagen de advertencia
                  Image.asset(
                    'assets/images/Warning.png',
                    height: 200,
                  ),
                  const SizedBox(height: 30),

                  // ⚠️ Mensaje de elegibilidad pendiente
                  const Text(
                    "Additional Information Required",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 📄 Explicación al usuario
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "We regret to inform you that your background check did not meet our eligibility criteria.\n\n"
                      "Your case requires further review, and we may need additional information from you.\n\n"
                      "Please check your email for more details regarding the next steps.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📩 Botón para contactar soporte o ver más detalles
                  ElevatedButton(
                    onPressed: () {
                      // Aquí podrías redirigir a una pantalla de contacto o soporte
                      print("Open Support");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // 🟠 Color de advertencia
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Contact Support",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // 🔄 Estado "Processing"
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40), // Subir la imagen un poco más
                // Imagen representativa
                Image.asset(
                  'assets/images/BackgroundVerification.png',
                  height: 180,
                ), // Aumentamos el tamaño ligeramente
                const SizedBox(height: 30),

                // Título y estado del background check
                const Text(
                  "Background Check Status",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD), // 🎨 Morado correcto
                  ),
                ),
                const SizedBox(height: 20),

                // Estado del background check
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                  decoration: BoxDecoration(
                    color: status == 'processing'
                        ? Colors.orange.withOpacity(0.1)
                        : const Color(0xFF6A0DAD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Status: $status",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: status == 'processing'
                          ? Colors.orange
                          : const Color(0xFF6A0DAD), // 🎨 Morado correcto
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Nota informativa para el usuario
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your background check request has been submitted, Please check your email to complete the process.\n"
                    "You will receive a response within 2 to 5 business days.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
