import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';

class DisableMemberAccount extends StatefulWidget {
  final String docId;
  DisableMemberAccount(this.docId);

  @override
  State<DisableMemberAccount> createState() => _DisableMemberAccountState(this.docId);
}

class _DisableMemberAccountState extends State<DisableMemberAccount> {
  final String docId;

  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool isDisabled = false;

  _DisableMemberAccountState(this.docId);

  @override
  void initState() {
    super.initState();
    checkIfDisabled();
  }

  Future<void> checkIfDisabled() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
    if (doc.exists) {
      setState(() {
        isDisabled = doc['status'] == 'disabled';
      });
    }
  }

  Future<void> _disableAccount() async {
    String user_Id = userId.text.trim();
    String passWord = password.text.trim();
    String confirm_Password = confirmPassword.text.trim();

    if (user_Id.isEmpty || passWord.isEmpty || confirm_Password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in all fields"),
      ));
      return;
    }

    if (passWord != confirm_Password) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match"),
      ));
      return;
    }

    try {
      // 🔍 Query the 'users' collection for the given userId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: user_Id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User not found."),
        ));
        return;
      }

      var doc = snapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;

      print("🟢 Entered userId: '$user_Id'");
      print("🟢 Entered password: '$passWord'");
      print("🔵 Firestore userId: '${data['userId'].toString().trim()}'");
      print("🔵 Firestore password: '${data['password'].toString().trim()}'");

      if (data['password'].toString().trim() == passWord) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .update({'status': 'disabled'});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Account '${user_Id}' has been disabled."),
        ));

        setState(() {
          isDisabled = true;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Incorrect password."),
        ));
      }
    } catch (e) {
      print("🔥 Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong."),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    if (isDisabled) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Account Disabled"),
          backgroundColor: Colors.grey,
        ),
        body: Center(
          child: Text("This account has been disabled."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Disable Member Account"),
        backgroundColor: Colors.grey,
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
              Text("Enter credentials to disable your account", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              TextField(
                controller: userId,
                decoration: InputDecoration(labelText: "User ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _disableAccount,
                child: Text("Disable Account"),
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
