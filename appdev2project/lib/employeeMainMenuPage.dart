import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appdev2project/memberAlterAccount.dart';
import 'package:appdev2project/renewMembershipPage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'loginpage.dart';

class EmployeeMainMenuPage extends StatefulWidget {
  String docId;
  EmployeeMainMenuPage(this.docId);

  @override
  State<EmployeeMainMenuPage> createState() => _EmployeeMainMenuPageState(docId);
}

class _EmployeeMainMenuPageState extends State<EmployeeMainMenuPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String docId;
  String userId ="";
  String fullName ="";
  String status="";
  DateTime expireDate = DateTime.now();
  Map<String, dynamic>? openingHours;
  int daysTillExpired = 0;
  _EmployeeMainMenuPageState(this.docId);

  Future<void> _fetchData() async {
    DocumentSnapshot snapshot = await firestore.collection('users').doc(docId).get();

    Map<String, dynamic> currentMember = snapshot.data() as Map<String, dynamic>;

    if ((currentMember['expireDate'] as Timestamp).toDate().isBefore(DateTime.now()) && currentMember['status'] != "expired") {
      await firestore.collection('users').doc(docId).update({'status': 'expired'});
      currentMember['status'] = 'expired';
    }
    setState(() {
      userId = currentMember['userId'];
      fullName = currentMember['fullName'];
      status = currentMember['status'];
      expireDate = (currentMember['expireDate'] as Timestamp).toDate();
      daysTillExpired = expireDate.difference(DateTime.now()).inDays;
      daysTillExpired = (daysTillExpired < 0) ? 0 : daysTillExpired;
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
    if (openingHours == null) {
      return "Loading opening hours...";
    }

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
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return '';
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
        title: Text("MMS Gym Application \nWelcome, ${fullName}", style: TextStyle(fontSize: 15),),
        backgroundColor: Colors.grey,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],

      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15,),
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RenewMembershipPage("", 0, DateTime.now(), "employee"),
                ),
              );
            }, child: Text("Renew Membsership"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 44),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),),),
            SizedBox(height: 15,),
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberAlterAccount(docId),
                ),
              );

            }, child: Text("Alter Account"), style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 44),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),),),

            SizedBox(height: 15,),
            ElevatedButton(onPressed: () {

            }
              , child: Text("View Location on Map"), style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 44),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),),),
            SizedBox(height: 15,),
            Text("Current Membership Status is: $status"),
            SizedBox(height: 15,),
            Text("Your membership expires in ${daysTillExpired} days on ${expireDate.year}-${expireDate.month.toString()}-${expireDate.day.toString()}"),
            SizedBox(height: 15,),
            Text("The gym is currently: ${_getGymStatus()} "),

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
                  Text(
                    'Opening Hours:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Monday: ${openingHours!['monday']['open']} - ${openingHours!['monday']['close']}'),
                  Text('Tuesday: ${openingHours!['tuesday']['open']} - ${openingHours!['tuesday']['close']}'),
                  Text('Wednesday: ${openingHours!['wednesday']['open']} - ${openingHours!['wednesday']['close']}'),
                  Text('Thursday: ${openingHours!['thursday']['open']} - ${openingHours!['thursday']['close']}'),
                  Text('Friday: ${openingHours!['friday']['open']} - ${openingHours!['friday']['close']}'),
                  Text('Saturday: ${openingHours!['saturday']['open']} - ${openingHours!['saturday']['close']}'),
                  Text('Sunday: ${openingHours!['sunday']['open']} - ${openingHours!['sunday']['close']}'),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
