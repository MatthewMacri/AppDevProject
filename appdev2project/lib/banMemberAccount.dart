import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customDrawer.dart'; // Import your custom Drawer here

class BanMemberAccount extends StatefulWidget {
  final String docId;

  BanMemberAccount(this.docId);

  @override
  State<BanMemberAccount> createState() => _BanMemberAccountState(this.docId);
}

class _BanMemberAccountState extends State<BanMemberAccount> {
  final String docId;

  TextEditingController userId = TextEditingController();
  TextEditingController employeePassword = TextEditingController();
  TextEditingController banReason = TextEditingController();

  String fullName = '';
  String userType = '';
  String status = '';
  DateTime expireDate = DateTime.now();
  int daysTillExpired = 0;

  _BanMemberAccountState(this.docId);

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
    employeePassword.clear();
    banReason.clear();
  }

  Future<void> _banAccount() async {
    String user_Id = userId.text.trim();
    String empPassword = employeePassword.text.trim();
    String reason = banReason.text.trim();

    if (user_Id.isEmpty || empPassword.isEmpty || reason.isEmpty) {
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

      if (data['status'] == 'banned') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User '$memberFullName' ($user_Id) is already banned."),
        ));
        _clearFields();
        return;
      }

      bool confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm Permanent Ban"),
          content: Text(
              "Are you sure you want to permanently ban:\n\n"
                  "Name: $memberFullName\n"
                  "User ID: $user_Id\n\n"
                  "Reason for Ban:\n\"$reason\""
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
        password: empPassword,
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
        'status': 'banned',
        'banReason': reason,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User '$memberFullName' ($user_Id) has been permanently banned."),
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
        title: Text("Permanently Ban Member"),
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
              Text("Enter details to ban a member", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextField(
                controller: userId,
                decoration: InputDecoration(labelText: "Member User ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: employeePassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Your Password (Employee)"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: banReason,
                decoration: InputDecoration(labelText: "Reason for Ban"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _banAccount,
                child: Text("Ban Member"),
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
