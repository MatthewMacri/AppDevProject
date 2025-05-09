import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appdev2project/customDrawer.dart';
import 'memberMainMenuPage.dart';

class RenewMembershipPage extends StatefulWidget {
  final String docId;
  final int amountOfDays;
  final DateTime expireDate;
  final String userType;

  RenewMembershipPage(this.docId, this.amountOfDays, this.expireDate, this.userType);

  @override
  State<RenewMembershipPage> createState() => _RenewMembershipPageState();
}

class _RenewMembershipPageState extends State<RenewMembershipPage> {
  String? selectedMemberDocId;
  DateTime? selectedMemberExpireDate;
  bool canRenew = false;
  List<QueryDocumentSnapshot> members = [];

  TextEditingController fullName = TextEditingController();
  TextEditingController creditCardNumber = TextEditingController();
  TextEditingController cvv = TextEditingController();

  // Variables for Drawer
  String userType = '';
  String currentFullName = '';
  String currentStatus = '';
  int currentDaysTillExpired = 0;
  DateTime currentExpireDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchUserTypeAndDetails();

    if (widget.userType == 'employee') {
      fetchAllMembers();
    } else {
      selectedMemberDocId = widget.docId;
      selectedMemberExpireDate = widget.expireDate;
      canRenew = widget.amountOfDays < 10;
    }
  }

  Future<void> fetchUserTypeAndDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .get();

    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    int daysLeft = 0;
    DateTime expDate = DateTime.now();

    if(userType == "member") {
      DateTime expDate = (userData['expireDate'] as Timestamp).toDate();
      int daysLeft = expDate.difference(DateTime.now()).inDays;
      daysLeft = (daysLeft < 0) ? 0 : daysLeft;
    }

    setState(() {
      userType = userData['type'];
      currentFullName = userData['fullName'];
      currentStatus = userData['status'];
      currentDaysTillExpired = daysLeft;
      currentExpireDate = expDate;
    });
  }

  Future<void> fetchAllMembers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'member')
        .get();

    setState(() {
      members = snapshot.docs;
    });
  }

  void _checkMemberRenewalStatus(DocumentSnapshot doc) {
    Timestamp expireTimestamp = doc['expireDate'];
    selectedMemberExpireDate = expireTimestamp.toDate();
    selectedMemberDocId = doc.id;

    final remainingDays = selectedMemberExpireDate!.difference(DateTime.now()).inDays;
    setState(() {
      canRenew = remainingDays < 10;
    });
  }

  void _renewMembership() async {
    try {
      if (selectedMemberExpireDate == null || selectedMemberDocId == null) return;

      DateTime today = DateTime.now();
      DateTime baseDate = selectedMemberExpireDate!.isBefore(today) ? today : selectedMemberExpireDate!;
      DateTime newExpireDate = baseDate.add(Duration(days: 365));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedMemberDocId)
          .update({'expireDate': Timestamp.fromDate(newExpireDate)});

      setState(() {
        selectedMemberExpireDate = newExpireDate;
        canRenew = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Membership Renewed! New Expiry: $newExpireDate"),
      ));

      if (widget.userType == "member") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => memberMainMenuPage(widget.docId)),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Renew Membership"),
        backgroundColor: Colors.grey,
      ),
      drawer: AppDrawer(
        docId: widget.docId,
        userRole: widget.userType,
        fullName: currentFullName,
        status: currentStatus,
        daysTillExpired: currentDaysTillExpired,
        expireDate: currentExpireDate,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: widget.userType == 'employee'
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a Member:"),
            DropdownButton<String>(
              value: selectedMemberDocId,
              hint: Text("Choose Member"),
              isExpanded: true,
              items: members.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['userId']),
                );
              }).toList(),
              onChanged: (value) {
                final doc = members.firstWhere((d) => d.id == value);
                _checkMemberRenewalStatus(doc);
              },
            ),
            SizedBox(height: 20),
            if (selectedMemberDocId != null && selectedMemberExpireDate != null)
              _buildRenewSection()
          ],
        )
            : _buildRenewSection(),
      ),
    );
  }

  Widget _buildRenewSection() {
    return canRenew
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Cost to renew for a Year: 120\$", style: TextStyle(fontSize: 20),),
        SizedBox(height: 30,),
        Text("Membership expires on: ${selectedMemberExpireDate?.toLocal()}"),
        SizedBox(height: 10),
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
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (fullName.text.isEmpty || creditCardNumber.text.isEmpty || cvv.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please fill in all fields")),
              );
              return;
            }
            _renewMembership();
          },
          child: Text("Renew Membership"),
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
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Membership cannot be renewed yet."),
        Text("Must be within 10 days of expiry."),
        if (selectedMemberExpireDate != null)
          Text("Expires: ${selectedMemberExpireDate?.toLocal()}"),
      ],
    );
  }
}
