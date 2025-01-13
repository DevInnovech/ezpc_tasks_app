import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
//import 'package:loading_switch/loading_switch.dart';

class AvailabilitySwitch extends StatefulWidget {
  const AvailabilitySwitch({Key? key}) : super(key: key);

  @override
  _AvailabilitySwitchState createState() => _AvailabilitySwitchState();
}

class _AvailabilitySwitchState extends State<AvailabilitySwitch> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserStream();
  }

  void fetchUserStream() {
    final user = _auth.currentUser;
    if (user != null) {
      userStream = _firestore.collection('users').doc(user.uid).snapshots();
    }
  }

  Future<void> updateAvailabilityStatus(bool status) async {
    setState(() {
      isLoading = true; // Muestra el estado de carga mientras se actualiza
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Actualizar el estado en Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'onDemand': status});
    } catch (e) {
      debugPrint("Error updating status: $e");
    } finally {
      setState(() {
        isLoading = false; // Finaliza el estado de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userStream == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data() == null) {
          return const Center(
            child: Text("Error fetching user data."),
          );
        }

        final data = snapshot.data!.data();
        final isAvailable = data?['onDemand'] ?? false;

        return AnimatedToggleSwitch<bool>.dual(
          style: ToggleStyle(
            borderColor: primaryColor.withOpacity(0.2),
          ),
          current: isAvailable,
          first: false,
          second: true,
          // borderColor: Colors.transparent,
          // innerColor: isAvailable ? Colors.green.shade300 : Colors.grey.shade300,
          /// indicatorColor: Colors.white,
          // height: 40.0,
          //indicatorSize: const Size(25, 25),
          borderWidth: 1.2,
          onChanged: (value) {
            updateAvailabilityStatus(value);
          },
          iconBuilder: (value) => value
              ? const Icon(Icons.check,
                  color: Color.fromARGB(255, 0, 255, 8), size: 18)
              : const Icon(Icons.close,
                  color: Color.fromARGB(255, 255, 17, 0), size: 18),
          textBuilder: (value) => value
              ? const Center(
                  child: Text('Available',
                      style: TextStyle(color: primaryColor, fontSize: 12)))
              : const Center(
                  child: Text('Offline',
                      style: TextStyle(color: primaryColor, fontSize: 12))),
        );
      },
    );
  }
}
