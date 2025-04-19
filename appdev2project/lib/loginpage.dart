import 'package:appdev2project/employeeMainMenuPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'memberMainMenuPage.dart';
import 'createMemberAccount.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
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


  Future<void> login() async {
    String userId = this.userId.text.trim();
    String password = this.password.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both fields")),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await firestore.collection('users').get();
      bool found = false;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          if (data['userId'] == userId && data['password'] == password) {
            found = true;

            Timestamp expireTimestamp = data['expireDate'];
            DateTime expireDate = expireTimestamp.toDate();
            DateTime now = DateTime.now();

            if (expireDate.isBefore(now)) {
              await firestore.collection('users').doc(doc.id).update({
                'status': 'expired',
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Membership has expired.")),
              );
              return;
            }

            if (data['type'] == "member") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => memberMainMenuPage(doc.id),
                ),
              );
            } else if (data['type'] == "employee"){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeMainMenuPage(doc.id),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MMS Gym Application"),
          backgroundColor: Colors.grey,
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
                    ElevatedButton(onPressed: login, child: Text("Login"),
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
              ),
              SizedBox(height: 20,),
            ],
          ),
        )
    );
  }
}


