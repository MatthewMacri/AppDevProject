import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loginpage.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAycnbMMRbR8mZYEJlATtUBvut6HeDNJR0",
          appId: "181754581464",
          messagingSenderId: "181754581464",
          projectId: "aplicationdev2project")
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateMemberAccount(),
    );
  }
}

class CreateMemberAccount extends StatefulWidget {
  const CreateMemberAccount({super.key});

  @override
  State<CreateMemberAccount> createState() => _CreateMemberAccountState();
}

class _CreateMemberAccountState extends State<CreateMemberAccount> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController firstName = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController userId = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController dateOfBirth = new TextEditingController();


  Future<void> signup() async {
    String firstName = this.firstName.text.trim();
    String lastName = this.lastName.text.trim();
    String userId = this.userId.text.trim();
    String password = this.password.text.trim();
    String dateOfBirth = this.dateOfBirth.text.trim(); // Still stored as a string

    if (firstName.isEmpty || lastName.isEmpty || userId.isEmpty || password.isEmpty || dateOfBirth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all fields")),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID already exists, login")),
        );
        return;
      }

      DateTime now = DateTime.now();
      DateTime expireDate = DateTime(now.year + 1, now.month, now.day);

      await FirebaseFirestore.instance.collection('users').add({
        'fullName': '$firstName $lastName',
        'userId': userId,
        'password': password,
        'type': 'member',
        'expireDate': Timestamp.fromDate(expireDate),
        'status': 'active', // or "expired"
        'dateOfBirth': dateOfBirth, // as string (e.g., "18/04/2000")
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup successful!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      print("Error during signup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during signup")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MMS Gym Application"),
          backgroundColor: Colors.grey,
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Container(
                width: 300,
                child: Column(
                  children: [
                    Text("First Name:"),
                    TextField(
                      controller: firstName,
                    ),
                    SizedBox(height: 10,),
                    Text("Last Name:"),
                    TextField(
                      controller: lastName,
                    ),
                    SizedBox(height: 10,),
                    Text("Enter a User ID:"),
                    TextField(
                      controller: userId,
                    ),
                    SizedBox(height: 10,),
                    Text("Create Password:"),
                    TextField(
                      controller: password,
                      obscureText: true,
                    ),
                    SizedBox(height: 10,),
                    Text("Date of Birth (DD/MM/YYYY):"),
                    TextField(
                      controller: dateOfBirth,
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () {
                        signup();
                      },
                      child: Text('Create Account'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 44),
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: CupertinoColors.lightBackgroundGray
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        )
    );
  }
}


