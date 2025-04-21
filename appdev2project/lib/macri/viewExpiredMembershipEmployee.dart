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
      title: 'View All Members',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const ViewAllMembersScreen(),
    );
  }
}

class ViewAllMembersScreen extends StatelessWidget {
  const ViewAllMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View All Members"),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No members found."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['fullName'] ?? 'No Name'),
                      trailing: Text(data['userId']?.toString() ?? 'N/A'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
