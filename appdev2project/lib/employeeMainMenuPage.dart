import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appdev2project/memberAlterAccount.dart';
import 'package:appdev2project/renewMembershipPage.dart';
import 'package:appdev2project/banMemberAccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'baseLogin.dart';
import 'unused/loginpage.dart';
import 'package:appdev2project/customDrawer.dart';

class EmployeeMainMenuPage extends StatefulWidget {
  final String docId;
  EmployeeMainMenuPage(this.docId);

  @override
  State<EmployeeMainMenuPage> createState() => _EmployeeMainMenuPageState(docId);
}

class _EmployeeMainMenuPageState extends State<EmployeeMainMenuPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String docId;
  String userId = "";
  String fullName = "";
  String employeeSchedule = "";

  _EmployeeMainMenuPageState(this.docId);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot snapshot = await firestore.collection('employees').doc(docId).get();

    Map<String, dynamic> currentEmployee = snapshot.data() as Map<String, dynamic>;

    setState(() {
      userId = currentEmployee['uid'] ?? '';
      fullName = currentEmployee['name'] ?? '';
      employeeSchedule = currentEmployee['schedule'] ?? 'No schedule assigned yet.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application \nWelcome, $fullName", style: TextStyle(fontSize: 15)),
        backgroundColor: Colors.grey,
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
            Image.network("https://wod.guru/wp-content/uploads/2025/03/7-10.png", width: 350),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Weekly Schedule:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(employeeSchedule, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}