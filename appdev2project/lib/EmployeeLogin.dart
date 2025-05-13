import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createMemberAccount.dart';
import 'employeeMainMenuPage.dart';
import 'adminMainPage.dart';

class EmployeeLogin extends StatefulWidget {
  @override
  _EmployeeLoginState createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  void resetPassword() async {
    if (!email.text.contains('@')) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reset email sent.")));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending reset email.")));
    }
  }

  void handleLogin() async {
    String emailInput = email.text.trim();
    String passwordInput = password.text.trim();

    if (!emailInput.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid email.")));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailInput,
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
          var userData = snapshot.docs.first.data() as Map<String, dynamic>;
          String userType = userData['type'] ?? 'employee';

          if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminMainPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployeeMainMenuPage(snapshot.docs.first.id)),
            );
          }

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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
              color: CupertinoColors.lightBackgroundGray,
            ),
            child: Column(
              children: [
                Text("Employee Email:"),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                Text("Password:"),
                TextField(
                  controller: password,
                  obscureText: true,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: handleLogin,
                  child: Text("Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 44),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: resetPassword,
                  child: Text('Reset Password'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 44),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
