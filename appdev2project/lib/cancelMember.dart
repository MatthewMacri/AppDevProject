import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'memberMainMenuPage.dart';
import 'customDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CancelMemberAccount extends StatefulWidget {
  String docId;
  CancelMemberAccount(this.docId);

  @override
  State<CancelMemberAccount> createState() => _CancelMemberAccountState(this.docId);
}

class _CancelMemberAccountState extends State<CancelMemberAccount> {
  _CancelMemberAccountState(this.docId);

  String docId;
  TextEditingController memberUserID = TextEditingController();
  TextEditingController memberPassword = TextEditingController();
  TextEditingController confirmMemberPassword = TextEditingController();
  TextEditingController empPassword = TextEditingController();

  String fullName = '';
  String userType = '';
  String status = '';
  DateTime expireDate = DateTime.now();
  int daysTillExpired = 0;

  @override
  void initState() {
    super.initState();
    _fetchDrawerData();
  }

  Future<void> _fetchDrawerData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(docId).get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      setState(() {
        fullName = userData['fullName'] ?? '';
        userType = userData['type'] ?? 'employee';
        status = userData['status'] ?? '';
      });
    } catch (e) {
      print("Error fetching drawer data: $e");
    }
  }

  void _clearFields() {
    memberUserID.clear();
    memberPassword.clear();
    confirmMemberPassword.clear();
    empPassword.clear();
  }

  Future<void> _resetPassword() async {
    String user_Id = memberUserID.text.trim();
    String member_Password = memberPassword.text.trim();
    String confirm_Member_Password = confirmMemberPassword.text.trim();
    String employee_Password = empPassword.text.trim();

    if (user_Id.isEmpty || member_Password.isEmpty || confirm_Member_Password.isEmpty || employee_Password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in all fields."),
      ));
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: user_Id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User not found."),
        ));
        _clearFields();
        return;
      }

      var doc = snapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;
      String memberFullName = data['fullName'] ?? 'Unknown';

      bool confirmed = await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Confirm Member Cancellation"),
              content: Text(
                  "Are you sure you want to cancel the member's account?:\n\n"
                      "Name: $memberFullName\n"
                      "User ID: $user_Id\n\n"
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Exit"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Confirm", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );

      if (confirmed != true) return;

      User? employee = FirebaseAuth.instance.currentUser;
      if (employee == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No authenticated employee found."),
        ));
        return;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: employee.email!,
        password: employee_Password,
      );

      try {
        await employee.reauthenticateWithCredential(credential);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Incorrect employee password."),
        ));
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "User '$memberFullName' ($user_Id) account has been cancelled."),
      ));

      _clearFields();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong."),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cancel Member Account"),
        backgroundColor: Colors.grey,
      ),
      drawer: AppDrawer(
        docId: docId,
        userRole: userType,
        fullName: fullName,
        status: status,
        daysTillExpired: daysTillExpired,
        expireDate: expireDate,
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.lightBackgroundGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Enter details to update a member's password", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextField(
                controller: memberUserID,
                decoration: InputDecoration(labelText: "Member User ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: memberPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Member Password"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmMemberPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Member Password"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: empPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Employee Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text("Cancel Member Account"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 44),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
