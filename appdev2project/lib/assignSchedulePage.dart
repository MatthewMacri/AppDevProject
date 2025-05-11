// assign_schedule_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignSchedulePage extends StatefulWidget {
  @override
  _AssignSchedulePageState createState() => _AssignSchedulePageState();
}

class _AssignSchedulePageState extends State<AssignSchedulePage> {
  final _authIdController = TextEditingController();
  final Map<String, TextEditingController> _dayControllers = {
    'Monday': TextEditingController(),
    'Tuesday': TextEditingController(),
    'Wednesday': TextEditingController(),
    'Thursday': TextEditingController(),
    'Friday': TextEditingController(),
    'Saturday': TextEditingController(),
    'Sunday': TextEditingController(),
  };

  Future<void> assignSchedule() async {
    String authId = _authIdController.text.trim();
    print("Entered authId: '$authId'");

    Map<String, String> schedule = {
      for (var day in _dayControllers.keys)
        day.toLowerCase(): _dayControllers[day]!.text.trim()
    };

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('authId', isEqualTo: authId)
          .limit(1)
          .get();

      print('Found ${snapshot.docs.length} matching document(s)');

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({'schedule': schedule});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule assigned successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee not found. Check the auth ID.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Weekly Schedule'),
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _authIdController,
              decoration: InputDecoration(labelText: 'Employee Auth ID'),
            ),
            SizedBox(height: 20),
            for (var day in _dayControllers.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _dayControllers[day],
                  decoration: InputDecoration(labelText: '$day Schedule'),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: assignSchedule,
              child: Text('Assign Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}