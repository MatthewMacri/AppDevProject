// create_employee_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateEmployeePage extends StatefulWidget {
  @override
  _CreateEmployeePageState createState() => _CreateEmployeePageState();
}

class _CreateEmployeePageState extends State<CreateEmployeePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _userIdController = TextEditingController();

  Future<void> createEmployee() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String userId = _userIdController.text.trim();
    String dob = _dobController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'authId': userCredential.user!.uid,
        'fullName': name,
        'dateOfBirth': dob,
        'schedule': {
          'monday': '-',
          'tuesday': '-',
          'wednesday': '-',
          'thursday': '-',
          'friday': '-',
          'saturday': '-',
          'sunday': '-',
        },
        "type" : "employee",
        'userId': userId,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Employee created.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _userIdController.clear();
    _dobController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Create Employee'),
          backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _userIdController, decoration: InputDecoration(labelText: 'User Id')),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name')),
            TextField(controller: _dobController, decoration: InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: createEmployee, child: Text('Create')),
          ],
        ),
      ),
    );
  }
}