// assign_schedule_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignSchedulePage extends StatefulWidget {
  @override
  _AssignSchedulePageState createState() => _AssignSchedulePageState();
}

class _AssignSchedulePageState extends State<AssignSchedulePage> {
  final _emailController = TextEditingController();
  final _scheduleController = TextEditingController();

  Future<void> assignSchedule() async {
    String email = _emailController.text.trim();
    String schedule = _scheduleController.text.trim();

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(docId)
            .update({'schedule': schedule});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Schedule assigned')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Employee not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Schedule'), backgroundColor: Colors.grey),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Employee Email')),
            TextField(controller: _scheduleController, decoration: InputDecoration(labelText: 'Weekly Schedule')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: assignSchedule, child: Text('Assign')),
          ],
        ),
      ),
    );
  }
}