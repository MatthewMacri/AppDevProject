import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'memberMainMenuPage.dart';


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

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
    if (doc.exists) {
      setState(() {
        currentPasswordInDB = doc['password'];
      });
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

    if (oldPwd != currentPasswordInDB) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Current Password is Incorrect"),
      ));
      return;
    }

    try {
      Map<String, dynamic> updates = {};
      if (newName.isNotEmpty)
        updates['fullName'] = newName;

      if (newPwd.isNotEmpty)
        updates['password'] = newPwd;

      if (newId.isNotEmpty)
        updates['userId'] = newId;

      await FirebaseFirestore.instance.collection('users').doc(docId).update(updates);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User information updated successfully!"),
      ));

      Navigator.push(context, MaterialPageRoute(builder: (context) => memberMainMenuPage(docId)));

    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MMS Gym Application, Alter User Info", style: TextStyle(fontSize: 15)),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("To make changes, confirm your current password.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 420,
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
        )
      )
    );

  }
}
