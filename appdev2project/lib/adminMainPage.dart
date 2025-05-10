import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'baseLogin.dart';

class AdminMainPage extends StatelessWidget {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginBase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
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
          ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ],
        )
      ),
    );
  }
}
