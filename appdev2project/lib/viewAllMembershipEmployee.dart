import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customDrawer.dart'; // Assuming this exists for Drawer

class ViewAllMembershipEmployee extends StatelessWidget {
  final String employeeDocId;

  const ViewAllMembershipEmployee(this.employeeDocId);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View All Members',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: ViewAllMembersScreen(employeeDocId),
    );
  }
}

class ViewAllMembersScreen extends StatelessWidget {
  final String employeeDocId;

  const ViewAllMembersScreen( this.employeeDocId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View All Members"),
        backgroundColor: Colors.blue,
      ),
      drawer: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(employeeDocId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(child: Center(child: CircularProgressIndicator()));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Drawer(child: Center(child: Text("Employee data not found.")));
          }

          final employeeData = snapshot.data!.data() as Map<String, dynamic>;

          return AppDrawer(
            docId: employeeDocId,
            userRole: employeeData['type'] ?? 'employee',
            fullName: employeeData['fullName'] ?? 'Employee',
            status: employeeData['status'] ?? '',
            daysTillExpired: 0, // Not relevant for employees
            expireDate: DateTime.now(), // Not relevant for employees
          );
        },
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('type', isEqualTo: 'member').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No members found."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final expireDate = (data['expireDate'] as Timestamp?)?.toDate();
                    final status = data['status'] ?? 'Unknown';

                    return ListTile(
                      title: Text(data['fullName'] ?? 'No Name'),
                      subtitle: Text("Status: $status\nExpire Date: ${expireDate != null ? "${expireDate.toLocal()}".split(' ')[0] : 'N/A'}"),
                      trailing: Text(data['userId']?.toString() ?? 'N/A', style: TextStyle(fontSize: 15),),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
