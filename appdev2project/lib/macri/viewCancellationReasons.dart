import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      appId: "YOUR_APP_ID",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      projectId: "YOUR_PROJECT_ID",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cancellation Reason Viewer',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const CancellationReasonScreen(),
    );
  }
}

class CancellationReasonScreen extends StatefulWidget {
  const CancellationReasonScreen({super.key});

  @override
  State<CancellationReasonScreen> createState() => _CancellationReasonScreenState();
}

class _CancellationReasonScreenState extends State<CancellationReasonScreen> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String? cancellationReason;

  void fetchCancellationReason() async {
    String userId = userIdController.text.trim();
    String name = nameController.text.trim();

    if (userId.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both ID and Name")),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .where('fullName', isEqualTo: name)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          cancellationReason = "No record found for this user.";
        });
        return;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        cancellationReason = data['cancellationReason'] ?? "No reason provided.";
      });
    } catch (e) {
      setState(() {
        cancellationReason = "Error retrieving cancellation reason.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Cancellation Reasons"), backgroundColor: Colors.grey),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID:"),
                  TextField(controller: userIdController),
                  SizedBox(height: 10),
                  Text("Name:"),
                  TextField(controller: nameController),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchCancellationReason,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                    ),
                    child: Text("View Cancellation Reasons"),
                  ),
                ],
              ),
            ),
            if (cancellationReason != null) ...[
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  cancellationReason!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
