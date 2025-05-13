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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Assign Weekly Schedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/assignSchedule');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Create New Employee'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/createEmployee');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome, Admin!'),
      ),
    );
  }
}
