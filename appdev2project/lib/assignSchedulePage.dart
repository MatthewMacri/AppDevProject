// assign_schedule_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignSchedulePage extends StatefulWidget {
  @override
  _AssignSchedulePageState createState() => _AssignSchedulePageState();
}

class _AssignSchedulePageState extends State<AssignSchedulePage> {
  final _userIdController = TextEditingController();
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
    String userId = _userIdController.text.trim();
    print("Entered userId: '$userId'");

    for (var day in _dayControllers.keys) {
      String value = _dayControllers[day]!.text.trim();
      if (!isValidTimeFormat(value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid format for $day. Use format like: 08:00-14:00 or 0/- for day off.")),
        );
        return;
      }
    }

    Map<String, String> schedule = {
      for (var day in _dayControllers.keys)
        day.toLowerCase(): _dayControllers[day]!.text.trim()
    };

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'employee')
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
        clearAllFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee not found. Check the user ID.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void clearAllFields() {
    _userIdController.clear();
    for (var controller in _dayControllers.values) {
      controller.clear();
    }
  }


  bool isValidTimeFormat(String input) {
    if (input.isEmpty || input == '0' || input == '-') return true;
    if (input.contains('-')) {
      var parts = input.split('-');
      if (parts.length == 2) {
        final timeRegex = RegExp(r'^\d{2}:\d{2}$');
        return timeRegex.hasMatch(parts[0]) && timeRegex.hasMatch(parts[1]);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Weekly Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Format ex: 08:00-15:00 \n Enter 0 or - for day off"),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'Employee User ID'),
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