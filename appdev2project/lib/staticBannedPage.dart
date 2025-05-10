import 'package:flutter/material.dart';
import 'unused/loginpage.dart';

class BannedScreen extends StatelessWidget {
  final String banReason;
  BannedScreen( this.banReason);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Access Denied"),
        backgroundColor: Colors.red.shade900,
        centerTitle: true,
      ),
      backgroundColor: Colors.red.shade900,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 100, color: Colors.white),
              SizedBox(height: 30),
              Text(
                "Access Denied",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "You are permanently banned from the gym and this application.",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Reason:\n\"$banReason\"",
                style: TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}
