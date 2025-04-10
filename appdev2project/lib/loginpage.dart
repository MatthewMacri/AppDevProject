import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'memberMainMenuPage.dart';

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
    String userId = this.userId.text;
    String password = this.password.text;


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
            if(data['type'] == "member") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => memberMainMenuPage(doc.id)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => memberMainMenuPage(userId)),
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
      print(e);
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
                    Text("user ID:"),
                    TextField(
                      controller: userId,
                    ),
                    SizedBox(height: 10,),
                    Text("Password:"),
                    TextField(
                      controller: password,
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed: login, child: Text("Login")),
                    SizedBox(height: 10,)
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


