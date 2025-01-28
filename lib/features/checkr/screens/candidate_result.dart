import 'package:ezpc_tasks_app/features/checkr/model/checkr_service.dart';
import 'package:flutter/material.dart';

class BackgroundCheckStatusScreen extends StatefulWidget {
  final String reportId;

  const BackgroundCheckStatusScreen({super.key, required this.reportId});

  @override
  _BackgroundCheckStatusScreenState createState() =>
      _BackgroundCheckStatusScreenState();
}

class _BackgroundCheckStatusScreenState
    extends State<BackgroundCheckStatusScreen> {
  String status = "Processing";

  @override
  void initState() {
    super.initState();
    //  _fetchStatus();
  }

/*
  Future<void> _fetchStatus() async {
    final result =
        await CheckrService.fetchBackgroundCheckStatus(widget.reportId);
    setState(() {
      status = result;
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Background Check Status")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your background check status is:",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
