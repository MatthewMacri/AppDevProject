import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appdev2project/memberAlterAccount.dart';
import 'package:appdev2project/renewMembershipPage.dart';
import 'package:appdev2project/banMemberAccount.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'baseLogin.dart';
import 'unused/loginpage.dart';
import 'package:appdev2project/customDrawer.dart'; // Assuming you have this for Drawer

class EmployeeMainMenuPage extends StatefulWidget {
  String docId;
  EmployeeMainMenuPage(this.docId);

  @override
  State<EmployeeMainMenuPage> createState() => _EmployeeMainMenuPageState(docId);
}

class _EmployeeMainMenuPageState extends State<EmployeeMainMenuPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String docId;
  String userId = "";
  String fullName = "";
  Map<String, dynamic>? openingHours;

  _EmployeeMainMenuPageState(this.docId);

  Future<void> _fetchData() async {
    DocumentSnapshot snapshot = await firestore.collection('users').doc(docId).get();

    Map<String, dynamic> currentMember = snapshot.data() as Map<String, dynamic>;

    setState(() {
      userId = currentMember['userId'];
      fullName = currentMember['fullName'];
    });
  }

  Future<void> _fetchOpeningHours() async {
    String jsonString = await rootBundle.loadString('assets/openHours.json');
    setState(() {
      openingHours = json.decode(jsonString);
    });
  }

  int _getCurrentDay() {
    return DateTime.now().weekday;
  }

  String _getGymStatus() {
    if (openingHours == null) return "Loading opening hours...";

    int currentDay = _getCurrentDay();
    String dayName = _getDayName(currentDay);

    if (openingHours!.containsKey(dayName)) {
      String openTimeStr = openingHours![dayName]['open'];
      String closeTimeStr = openingHours![dayName]['close'];

      DateTime now = DateTime.now();
      DateTime openTime = _parseTime(now, openTimeStr);
      DateTime closeTime = _parseTime(now, closeTimeStr);

      if (now.isAfter(openTime) && now.isBefore(closeTime)) {
        return "open.";
      } else {
        return "closed.";
      }
    } else {
      return "";
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return '';
    }
  }

  DateTime _parseTime(DateTime now, String timeStr) {
    List<String> parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchOpeningHours();
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
            Image.network("https://wod.guru/wp-content/uploads/2025/03/7-10.png", width: 350,),
            SizedBox(height: 15),
            Text("The gym is currently: ${_getGymStatus()}"),
            SizedBox(height: 35),
            openingHours == null
                ? Text("Loading opening hours...")
                : Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Opening Hours:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  for (var day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])
                    Text('$day: ${openingHours![day]['open']} - ${openingHours![day]['close']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
