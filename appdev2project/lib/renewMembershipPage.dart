import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RenewMembershipPage extends StatefulWidget {
  String docId;
  int amountOfDays;
  DateTime expireDate = DateTime.now();
  RenewMembershipPage(this.docId ,this.amountOfDays, this.expireDate);

  @override
  State<RenewMembershipPage> createState() => _RenewMembershipPageState(this.docId ,this.amountOfDays, this.expireDate);
}

class _RenewMembershipPageState extends State<RenewMembershipPage> {
  String docId;
  int amountOfDays;
  DateTime expireDate = DateTime.now();
  bool canRenew = false;
  _RenewMembershipPageState(this.docId, this.amountOfDays, this.expireDate );

  TextEditingController fullName = TextEditingController();
  TextEditingController creditCardNumber = TextEditingController();
  TextEditingController cvv = TextEditingController();

  @override
  void initState() {
    super.initState();
    canRenew = amountOfDays < 10;
  }

  void _renewMembership() async {
    try {

        DateTime newExpireDate = expireDate.add(Duration(days: 365));

        await FirebaseFirestore.instance.collection('users').doc(docId).update({
          'expireDate': Timestamp.fromDate(newExpireDate), // Convert DateTime to Timestamp
        });

        setState(() {
          this.expireDate = newExpireDate;
          this.amountOfDays += 365;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Membership Renewed! New Expiry Date: ${newExpireDate.toLocal()}"),
        ));

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("MMS Gym Application, Renew Membership", style: TextStyle(fontSize: 15)
      ), ),
      body: Center(
        child: Column(
          children: [
            if (canRenew)
              Column(
                children: [
                  Text("Please enter your credit card details to renew your membership.", style: TextStyle(fontSize: 16)),
                  Text("Cost: \$100 for a year.", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 20),
                  TextField(
                    controller: fullName,
                    decoration: InputDecoration(labelText: "Full Name on Credit Card"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: creditCardNumber,
                    decoration: InputDecoration(labelText: "Credit Card Number"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: cvv,
                    decoration: InputDecoration(labelText: "CVV"),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _renewMembership,
                    child: Text("Renew Membership"),
                  ),
                ],
              )
            else
            // Show message if cannot renew
              Column(
                children: [
                  Text(
                    "Sorry, you cannot renew your membership.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Memberships must be expiring within ten days to be eligible for renewal.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Memberships Expires is $amountOfDays days.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],

        )
    )
    );
  }
}
