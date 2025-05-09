import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../employeeMainMenuPage.dart';
import '../createMemberAccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../memberMainMenuPage.dart';
import '../staticBannedPage.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null, // Use default icon
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
        projectId: "aplicationdev2project")
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController userId = new TextEditingController();
  TextEditingController password = new TextEditingController();

  void handleLogin() async {
    String userIdInput = this.userId.text.trim();
    String passwordInput = this.password.text.trim();

    if (userIdInput.contains('@')) {
      // Employee login (no ban check needed)
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userIdInput,
          password: passwordInput,
        );

        User? user = FirebaseAuth.instance.currentUser;
        await user?.reload();

        if (user != null && user.emailVerified) {
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('authId', isEqualTo: user.uid)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeMainMenuPage(snapshot.docs.first.id),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No Firestore record found for this employee.")),
            );
          }
        } else {
          await user?.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email not verified. A verification email has been sent.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password for employee.")),
        );
      }
    } else {
      // Member login (check for ban)
      try {
        QuerySnapshot snapshot = await firestore.collection('users').get();
        bool found = false;

        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (data != null && data is Map<String, dynamic>) {
            if (data['userId'] == userIdInput && data['password'] == passwordInput) {
              found = true;

              if (data['type'] == "member") {
                if (data['status'] == 'banned') {
                  showBanDialog(data['banReason']);
                  return;
                }

                Timestamp expireTimestamp = data['expireDate'];
                DateTime expireDate = expireTimestamp.toDate();
                DateTime now = DateTime.now();

                if (expireDate.isBefore(now)) {
                  await firestore.collection('users').doc(doc.id).update({
                    'status': 'expired',
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => memberMainMenuPage(doc.id)),
                );
              }
              break;
            }
          }
        }

        if (!found) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid credentials, Please try again")),
          );
        }
      } catch (e) {
        print("Login error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred during login")),
        );
      }
    }
  }

  void showBanDialog(String? reason) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BannedScreen(reason.toString())));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Access Denied"),
        content: Text(
            "Your account has been permanently banned from the gym.\n\n"
                "Reason: ${reason ?? 'No reason provided.'}\n\n"
                "You are not allowed to access the gym or this application again."
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              userId.clear();
              password.clear();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
  }

  void requestNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Show dialog to request permissions
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application"),
        backgroundColor: Colors.grey,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
            children: [
              SizedBox(height: 50,),
              Container(
                width: 300,
                child: Column(
                  children: [
                    Text("User ID:"),
                    TextField(
                      controller: userId,
                    ),
                    SizedBox(height: 10,),
                    Text("Password:"),
                    TextField(
                      controller: password,
                      obscureText: true,
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed: handleLogin, child: Text("Login"),
                      style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 44),
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),),),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateMemberAccount()),
                        );
                      },
                      child: Text('Create Account'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 44),
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(20),
                  color: CupertinoColors.lightBackgroundGray
                ),
              )
            ],
          ),
        )

      );
  }
}


