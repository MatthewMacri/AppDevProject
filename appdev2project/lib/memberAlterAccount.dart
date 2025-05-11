import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'memberMainMenuPage.dart';
import 'customDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberAlterAccount extends StatefulWidget {
  String docId;
  MemberAlterAccount(this.docId);

  @override
  State<MemberAlterAccount> createState() => _MemberAlterAccountState(this.docId);
}

class _MemberAlterAccountState extends State<MemberAlterAccount> {
  _MemberAlterAccountState(this.docId);

  String docId;
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newFullName = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newUserId = TextEditingController();

  String currentPasswordInDB = "";

  String fullName = ' ';
  String userType = ' ';
  String status = '';
  int daysTillExpired = 0;
  DateTime expireDate = DateTime.now();

  @override
  void initState() {
    super.initState();
     _fetchUserData();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(docId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("DEBUG: Firestore User Data: $data");

        String accountType = data['type'] ?? '';
        print("DEBUG: Account Type Detected: $accountType");

        if (accountType == 'employee') {
          currentPasswordInDB = 'FIREBASE_AUTH';
          print("DEBUG: Set currentPasswordInDB = FIREBASE_AUTH for employee.");
        } else {
          currentPasswordInDB = data['password'] ?? '';
          print("DEBUG: Set currentPasswordInDB = $currentPasswordInDB for member.");
        }

        setState(() {});
      }
    } catch (e) {
      print("Error fetching current user data: $e");
    }
  }


  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      Map<String, dynamic> userData =
      snapshot.data() as Map<String, dynamic>;

      print (userData);
      int daysLeft = 0;
      DateTime expDate = DateTime.now();

      userType = userData['type'];
      if(userType == "member") {
        expDate = (userData['expireDate'] as Timestamp).toDate();
        daysLeft = expDate.difference(DateTime.now()).inDays;
        daysLeft = (daysLeft < 0) ? 0 : daysLeft;
      }

      setState(() {
        fullName = userData['fullName'] ?? '';
        userType = userData['type'] ?? '';
        status = userData['status'] ?? '';
        expireDate = expDate;
        daysTillExpired = daysLeft;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _alterUserInfo() async {
    String oldPwd = currentPassword.text;
    String newName = newFullName.text;
    String newPwd = newPassword.text;
    String newId = newUserId.text;

    if (oldPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter your current password to make changes"),
      ));
      return;
    }

    if (newName.isEmpty && newPwd.isEmpty && newId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter at least New Password OR New Full Name OR New User ID"),
      ));
      return;
    }

    try {
      if (currentPasswordInDB == 'FIREBASE_AUTH') {

        // Employee: Verify using FirebaseAuth
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No authenticated employee found."),
          ));
          return;
        }

        // Reauthenticate with current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPwd,
        );

        try {
          await user.reauthenticateWithCredential(credential);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Invalid email or password for employee."),
          ));
          return;
        }

        if (newPwd.isNotEmpty) {
          await user.updatePassword(newPwd);
        }

      } else {

        if (oldPwd != currentPasswordInDB) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Current password is incorrect."),
          ));
          return;
        }
      }

      // Update Firestore for both member and employee
      Map<String, dynamic> updates = {};
      if (newName.isNotEmpty) updates['fullName'] = newName;
      if (newPwd.isNotEmpty && currentPasswordInDB != 'FIREBASE_AUTH') {
        updates['password'] = newPwd;
      }
      if (newId.isNotEmpty) updates['userId'] = newId;

      await FirebaseFirestore.instance.collection('users').doc(docId).update(updates);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User information updated successfully!"),
      ));

      currentPassword.clear();
      newFullName.clear();
      newPassword.clear();
      newUserId.clear();

    } catch (e) {
      print("Error during user info update: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred while updating."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application, Alter User Info", style: TextStyle(fontSize: 15)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "To make changes, confirm your current password.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                color: CupertinoColors.lightBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  TextField(
                    controller: currentPassword,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Current Password"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: newFullName,
                    decoration: InputDecoration(labelText: "New Full Name (optional)"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: newPassword,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "New Password (optional)"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: newUserId,
                    decoration: InputDecoration(labelText: "New User ID (optional)"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _alterUserInfo,
                    child: Text("Update Info"),
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
      ),
      drawer: AppDrawer(
        docId: docId,
        userRole: userType,
        fullName: fullName,
        status: status,
        daysTillExpired: daysTillExpired,
        expireDate: expireDate,
      ),
    );
  }
}

