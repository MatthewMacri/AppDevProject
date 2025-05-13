import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unused/loginpage.dart';

class MemberAccountPayment extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String userId;
  final String password;
  final String dateOfBirth;

  MemberAccountPayment(this.firstName, this.lastName, this.userId, this.password, this.dateOfBirth,
  );

  @override
  _MemberAccountPaymentState createState() => _MemberAccountPaymentState();
}

class _MemberAccountPaymentState extends State<MemberAccountPayment> {
  TextEditingController fullName = TextEditingController();
  TextEditingController creditCardNumber = TextEditingController();
  TextEditingController cvv = TextEditingController();

  void completeSignup() async {
    if (fullName.text.isEmpty || creditCardNumber.text.isEmpty || cvv.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all payment fields.")),
      );
      return;
    }

    DateTime now = DateTime.now();
    DateTime expireDate = DateTime(now.year + 1, now.month, now.day);

    await FirebaseFirestore.instance.collection('users').add({
      'fullName': '${widget.firstName} ${widget.lastName}',
      'userId': widget.userId,
      'password': widget.password,
      'type': 'member',
      'expireDate': Timestamp.fromDate(expireDate),
      'status': 'active',
      'dateOfBirth': widget.dateOfBirth,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account created successfully!")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Payment Information"),
          backgroundColor: Colors.blue),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text("Cost for a Year: 120\$", style: TextStyle(fontSize: 20),),
              SizedBox(height: 30,),
              Text("Enter Payment Details to Complete Account Creation"),
              SizedBox(height: 20),
              TextField(
                controller: fullName,
                decoration: InputDecoration(labelText: "Full Name on Credit Card"),
              ),
              TextField(
                controller: creditCardNumber,
                decoration: InputDecoration(labelText: "Credit Card Number"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cvv,
                decoration: InputDecoration(labelText: "CVV"),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: completeSignup,
                child: Text("Complete Signup"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 44),
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
