import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'baseLogin.dart';
import 'package:appdev2project/customDrawer.dart';

class EmployeeMainMenuPage extends StatefulWidget {
  final String docId;
  EmployeeMainMenuPage(this.docId);

  @override
  State<EmployeeMainMenuPage> createState() => _EmployeeMainMenuPageState(docId);
}

class _EmployeeMainMenuPageState extends State<EmployeeMainMenuPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String docId;

  String userId = "";
  String fullName = "";
  Map<String, dynamic> schedule = {};

  _EmployeeMainMenuPageState(this.docId);

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await firestore
        .collection('users')
        .where('authId', isEqualTo: currentUid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      setState(() {
        userId = data['userId'] ?? '';
        fullName = data['fullName'] ?? '';
        schedule = Map<String, dynamic>.from(data['schedule'] ?? {});
      });
    }
  }

  String capitalize(String text) =>
      text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;

  String formatTime(String? time) {
    if (time == null || time.trim() == '0' || time.trim() == '-') return 'Off';
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application \nWelcome, $fullName", style: TextStyle(fontSize: 15)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginBase()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        docId: docId,
        userRole: 'employee',
        fullName: fullName,
        status: '',
        daysTillExpired: 0,
        expireDate: DateTime.now(),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15),
            // Fallback option for broken image
            Image.asset('assets/gym_banner.png', width: 350, errorBuilder: (context, error, stackTrace) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Welcome to your dashboard!", style: TextStyle(fontSize: 18)),
              );
            }),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Weekly Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 12),
                  if (schedule.isEmpty)
                    Text('No schedule assigned.', style: TextStyle(fontSize: 16)),
                  for (var day in [
                    'monday',
                    'tuesday',
                    'wednesday',
                    'thursday',
                    'friday',
                    'saturday',
                    'sunday',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            capitalize(day),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            formatTime(schedule[day]),
                            style: TextStyle(
                              fontSize: 16,
                              color: formatTime(schedule[day]) == 'Off' ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}