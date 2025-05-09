import 'package:appdev2project/customDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';


import 'baseLogin.dart';
import 'unused/loginpage.dart';

class memberMainMenuPage extends StatefulWidget {
  String docId;
  memberMainMenuPage(this.docId);

  @override
  State<memberMainMenuPage> createState() => _memberMainMenuPageState(docId);
}

class _memberMainMenuPageState extends State<memberMainMenuPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String docId;
  String userId ="";
  String fullName ="";
  String status="";
  DateTime expireDate = DateTime.now();
  Map<String, dynamic>? openingHours;
  int daysTillExpired = 0;
  _memberMainMenuPageState(this.docId);

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
      createNotification();
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
    requestNotificationPermissions();
  }



  void requestNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void createNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100 + DateTime.now().millisecondsSinceEpoch % 1000,
        channelKey: 'basic_channel',
        title: 'Membership Expiration Reminder',
        body: 'Hi $fullName, your membership expires in $daysTillExpired days.',
        notificationLayout: NotificationLayout.Default,
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application", style: TextStyle(fontSize: 15),),

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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15,),
            Image.network("https://images.pexels.com/photos/260352/pexels-photo-260352.jpeg", height: 300,),
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
      drawer: AppDrawer(
        docId: docId,
        userRole: 'member',
        fullName: fullName,
        status: status,
        daysTillExpired: daysTillExpired,
        expireDate: expireDate,
      ),
    );
  }
}
