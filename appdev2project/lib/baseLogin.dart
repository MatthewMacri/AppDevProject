import 'EmployeeLogin.dart';
import 'MemberLogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAycnbMMRbR8mZYEJlATtUBvut6HeDNJR0",
      appId: "181754581464",
      messagingSenderId: "181754581464",
      projectId: "aplicationdev2project",
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
      home: LoginBase(),
    );
  }
}

class LoginBase extends StatefulWidget {
  @override
  State<LoginBase> createState() => _LoginBaseState();
}

class _LoginBaseState extends State<LoginBase> {
  bool isEmployee = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application"),
        backgroundColor: Colors.grey,
        actions: [
          Row(
            children: [
              Text(
                isEmployee ? "Employee" : "Member",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Switch(
                value: isEmployee,
                onChanged: (value) {
                  setState(() {
                    isEmployee = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(width: 10), // Add spacing on the right edge
        ],
      ),
      body: Center(
        child: isEmployee ? EmployeeLogin() : MemberLogin(),
      ),
    );
  }
}