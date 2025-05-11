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

  Future<void> createEmployee() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String dob = _dobController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('your_actual_collection_name').doc(userCredential.user!.uid).set({
        'authId': userCredential.user!.uid,
        'email': email,
        'name': name,
        'dob': dob,
        'schedule': {
          'monday': '-',
          'tuesday': '-',
          'wednesday': '-',
          'thursday': '-',
          'friday': '-',
          'saturday': '-',
          'sunday': '-',
        },
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Employee created.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Employee'), backgroundColor: Colors.grey),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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