import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Membership Views',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const MembershipViewsScreen(),
    );
  }
}

class MembershipViewsScreen extends StatelessWidget {
  const MembershipViewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Membership Views"),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, "View All Memberships", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MembershipListScreen(title: 'All Memberships'),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildButton(context, "View Expired Memberships", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MembershipListScreen(title: 'Expired Memberships'),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildButton(context, "View Cancellation Reasons", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MembershipListScreen(title: 'Cancellation Reasons'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildButton(BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      width: 250,
      height: 45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}

class MembershipListScreen extends StatelessWidget {
  final String title;
  const MembershipListScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Text(
          'This is the "$title" page.\nYou can display a Firestore list here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
