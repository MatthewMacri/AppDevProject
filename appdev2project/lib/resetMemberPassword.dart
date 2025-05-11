import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customDrawer.dart';

class ResetMemberPassword extends StatefulWidget {
  final String docId;

  ResetMemberPassword(this.docId);

  @override
  State<ResetMemberPassword> createState() => _ResetMemberPasswordState(this.docId);
}

class _ResetMemberPasswordState extends State<ResetMemberPassword> {
  final String docId;

  TextEditingController userId = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController empPassword = TextEditingController();

  String fullName = '';
  String userType = '';
  String status = '';
  DateTime expireDate = DateTime.now();
  int daysTillExpired = 0;

  _ResetMemberPasswordState(this.docId);

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
    userId.clear();
    newPassword.clear();
    confirmPassword.clear();
    empPassword.clear();
  }

  Future<void> _resetPassword() async {
    String user_Id = userId.text.trim();
    String new_Password = newPassword.text.trim();
    String confirm_Password = confirmPassword.text.trim();
    String employee_Password = empPassword.text.trim();

    if (user_Id.isEmpty || new_Password.isEmpty || confirm_Password.isEmpty || employee_Password.isEmpty) {
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
              title: Text("Confirm Reset Password"),
              content: Text(
                  "Are you sure you want to reset the password?:\n\n"
                      "Name: $memberFullName\n"
                      "User ID: $user_Id\n\n"
                      "Password: $new_Password\n\n"
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
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

      await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
        'password': confirm_Password
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "User '$memberFullName' ($user_Id) password has been reset."),
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
        title: Text("Reset Member Password"),
        backgroundColor: Colors.blue,
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
                controller: userId,
                decoration: InputDecoration(labelText: "Member User ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
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
                child: Text("Reset Password"),
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