import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'unused/loginpage.dart';
import 'staticBannedPage.dart';
import 'accountPayement.dart';

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


  void showBanDialog(String? reason) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BannedScreen(reason.toString())));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Access Denied"),
        content: Text(
            "Your account has been permanently banned from the gym.\n\n"
                "Reason: ${reason ?? 'No reason provided.'}\n\n"
                "You are not allowed to access the gym or this application again."
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              userId.clear();
              password.clear();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> signup() async {
    String firstNameInput = firstName.text.trim();
    String lastNameInput = lastName.text.trim();
    String fullNameInput = '$firstNameInput $lastNameInput';
    String userIdInput = userId.text.trim();
    String passwordInput = password.text.trim();
    String dateOfBirthInput = dateOfBirth.text.trim();

    if (firstNameInput.isEmpty || lastNameInput.isEmpty || userIdInput.isEmpty || passwordInput.isEmpty || dateOfBirthInput.isEmpty) {
      showLargeSnackBar("Please enter all fields");
      return;
    }

    try {
      // Check if user is banned
      QuerySnapshot bannedCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'banned')
          .where('type', isEqualTo: 'member')
          .get();

      for (var doc in bannedCheck.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String existingUserId = data['userId'] ?? '';
        String existingFullName = data['fullName'] ?? '';
        String banReason = data['banReason'] ?? 'No reason provided.';

        if (existingUserId == userIdInput || existingFullName.toLowerCase() == fullNameInput.toLowerCase()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BannedScreen( banReason)),
          );
          showBanDialog(banReason);
          return;
        }
      }

      // Check if user ID already exists
      QuerySnapshot userIdCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userIdInput)
          .get();

      if (userIdCheck.docs.isNotEmpty) {
        showLargeSnackBar("User ID already exists, please log in.");
        return;
      }

      // Navigate to Payment Page before finalizing account creation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberAccountPayment(firstNameInput, lastNameInput, userIdInput, passwordInput, dateOfBirthInput,
          ),
        ),
      );
    } catch (e) {
      print("Error during signup: $e");
      showLargeSnackBar("An error occurred during signup.");
    }
  }


  void showLargeSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        duration: Duration(seconds: 3),
      ),
    );
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


