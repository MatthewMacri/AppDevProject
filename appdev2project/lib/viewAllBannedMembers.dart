import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customDrawer.dart'; // Assuming this exists for Drawer

class ViewBannedMembers extends StatelessWidget {
  final String employeeDocId;

  const ViewBannedMembers(this.employeeDocId);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View Banned Members',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: ViewBannedMembersScreen(employeeDocId),
    );
  }
}

class ViewBannedMembersScreen extends StatelessWidget {
  final String employeeDocId;

  const ViewBannedMembersScreen(this.employeeDocId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Banned Members"),
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
            daysTillExpired: 0,
            expireDate: DateTime.now(),
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
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('type', isEqualTo: 'member')
                  .where('status', isEqualTo: 'banned')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No banned members found."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final expireDate = (data['expireDate'] as Timestamp?)?.toDate();
                    final banReason = data['banReason'] ?? 'No reason provided';

                    return ListTile(
                      title: Text(data['fullName'] ?? 'No Name'),
                      subtitle: Text(
                          "Ban Reason: $banReason"
                      ),
                      trailing: Text(data['userId']?.toString() ?? 'N/A', style: TextStyle(fontSize: 15)),
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
