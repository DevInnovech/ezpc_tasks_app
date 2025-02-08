import 'package:ezpc_tasks_app/features/checkr/screens/candidate_screen.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/material.dart';

class WelcomeBackgroundCheckScreen extends StatelessWidget {
  const WelcomeBackgroundCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/images/backgroundillustration.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A background check is required to continue using the application. It ensures a safe and reliable environment for all users.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "This process will be securely managed by Checkr, our trusted partner for background screening services. By proceeding, you agree to comply with Checkr's terms and conditions, ensuring a transparent and reliable verification process.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
                      builder: (context) => const CandidateFormScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.authenticationScreen,
                );
              },
              child: const Text(
                "Skip for now",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple,
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
