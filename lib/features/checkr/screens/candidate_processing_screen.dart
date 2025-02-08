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

  Future<void> updateUserStatus(String email) async {
    try {
      // Busca el documento del usuario por su email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;

        // Actualiza el estado del usuario a "approved"
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({'status': 'Approved'});
      } else {
        print("User with email $email not found.");
      }
    } catch (e) {
      print("Error updating user status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Background Check Status",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A0DAD),
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
              child: Text(
                "Candidate data not found.",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final status = data['status'] ?? 'Unknown';
          final result = data['result'] ?? 'Unknown';

          // ✅ Background check aprobado (clear)
          if (status == 'complete' && result == 'clear') {
            // Actualizar el estado del usuario a "approved"
            updateUserStatus(widget.email);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Success.png',
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Congratulations!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your background check has been completed successfully. "
                    "We are now ready to proceed!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteNames.authenticationScreen,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A0DAD),
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
                  Image.asset(
                    'assets/images/Warning.png',
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Additional Information Required",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  ElevatedButton(
                    onPressed: () {
                      print("Open Support");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/BackgroundVerification.png',
                  height: 180,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Background Check Status",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
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
                          : const Color(0xFF6A0DAD),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your background check request has been submitted. Please check your email to complete the process.\n"
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
