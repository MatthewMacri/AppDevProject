import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createMemberAccount.dart';
import 'memberMainMenuPage.dart';
import 'staticBannedPage.dart'; // Assuming this is your banned screen.

class MemberLogin extends StatefulWidget {
  @override
  State<MemberLogin> createState() => _MemberLoginState();
}

class _MemberLoginState extends State<MemberLogin> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController userId = TextEditingController();
  final TextEditingController password = TextEditingController();

  void handleLogin() async {
    String userIdInput = userId.text.trim();
    String passwordInput = password.text.trim();

    try {
      QuerySnapshot snapshot = await firestore.collection('users').get();
      bool found = false;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
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

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => memberMainMenuPage(doc.id)),
            );
          }
          break;
        }
      }

      if (!found) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials, please try again")),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during login")),
      );
    }
  }

  void showBanDialog(String? reason) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BannedScreen(reason ?? 'No reason provided')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Column(
          children: [
            SizedBox(height: 50),
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
                  Text("User ID:"),
                  TextField(controller: userId),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateMemberAccount()),
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
                ],
              ),
            ),
          ],
        ),
    );
  }
}
