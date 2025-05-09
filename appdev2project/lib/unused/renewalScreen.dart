import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      appId: "YOUR_APP_ID",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      projectId: "YOUR_PROJECT_ID",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RenewScreen(),
    );
  }
}

class RenewScreen extends StatefulWidget {
  const RenewScreen({super.key});

  @override
  State<RenewScreen> createState() => _RenewScreenState();
}

class _RenewScreenState extends State<RenewScreen> {
  TextEditingController userId = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  bool termsAccepted = false;

  void renewMembership() async {
    if (userId.text.isEmpty || fullName.text.isEmpty || cardNumber.text.isEmpty || address.text.isEmpty || !termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and accept the terms.'),
      ));
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User not found.'),
        ));
        return;
      }

      DocumentReference userDoc = snapshot.docs.first.reference;
      DateTime now = DateTime.now();
      DateTime newExpireDate = DateTime(now.year + 1, now.month, now.day);

      await userDoc.update({
        'expireDate': Timestamp.fromDate(newExpireDate),
        'status': 'active',
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Membership renewed successfully!'),
      ));
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Renewal failed. Try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Renewal screen"), backgroundColor: Colors.grey),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID:"),
                TextField(controller: userId),
                SizedBox(height: 20),
                Text("Credit Card Info", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Cost: \$10"),
                SizedBox(height: 10),
                Text("Full Name on credit card:"),
                TextField(controller: fullName),
                SizedBox(height: 10),
                Text("Credit card Number and CVV:"),
                TextField(controller: cardNumber),
                SizedBox(height: 10),
                Text("Billing Address:"),
                TextField(
                  controller: address,
                  maxLines: 2,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          termsAccepted = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text("I accept the terms\nDO NOT CONTEST THE CHARGE"),
                    )
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: renewMembership,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 44),
                  ),
                  child: Text("Renew Membership"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}