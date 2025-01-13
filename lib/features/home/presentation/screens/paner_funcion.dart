import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Stream<List<Map<String, dynamic>>> getCollaboratorRequests(String providerId) {
  try {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'Pending') // Filter only pending requests
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  } catch (e) {
    debugPrint("Error in stream: $e");
    return Stream.value([]); // Return an empty stream in case of errors
  }
}

Widget buildCollaboratorRequests() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const SizedBox.shrink();
  }
  final providerId = user.uid;

  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: getCollaboratorRequests(providerId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Text("Error loading requests: ${snapshot.error}"),
        );
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const SizedBox.shrink();
      }

      final requests = snapshot.data!;

      return ListView.builder(
        shrinkWrap: true,
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(request['senderId'])
                .get(), // Get sender details
            builder: (context, senderSnapshot) {
              if (senderSnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final senderData =
                  senderSnapshot.data?.data() as Map<String, dynamic>?;

              return Card(
                child: ListTile(
                  title: Text(request['taskName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${request['status']}"),
                      Text(
                          "Sent by: ${senderData?['name'] ?? request['collaborators']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _respondToRequest(request, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _respondToRequest(request, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Future<void> _respondToRequest(
    Map<String, dynamic> request, bool accepted) async {
  try {
    // Check if required fields are present
    if (request['id'] == null ||
        request['taskId'] == null ||
        request['providerId'] == null) {
      throw Exception("Invalid request data.");
    }

    // Update the notification status
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(request['id'])
        .update({
      'status': accepted ? 'Accepted' : 'Rejected',
    });

    // If accepted, add to collaborators
    if (accepted) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final taskRef = FirebaseFirestore.instance
            .collection('tasks')
            .doc(request['taskId']);

        final snapshot = await transaction.get(taskRef);

        if (!snapshot.exists) {
          throw Exception("Task not found.");
        }

        transaction.update(taskRef, {
          'collaborators': FieldValue.arrayUnion([request['providerId']]),
        });
      });
    }
  } catch (e) {
    debugPrint("Error responding to request: $e");
  }
}
