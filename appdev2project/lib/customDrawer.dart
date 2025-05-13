import 'package:appdev2project/cancelMember.dart';
import 'package:flutter/material.dart';
import 'package:appdev2project/memberAlterAccount.dart';
import 'package:appdev2project/renewMembershipPage.dart';
import 'package:appdev2project/memberMainMenuPage.dart';
import 'baseLogin.dart';
import 'employeeMainMenuPage.dart';
import 'locationMap.dart';
import 'banMemberAccount.dart';
import 'unused/loginpage.dart';
import 'viewAllMembershipEmployee.dart';
import 'viewAllBannedMembers.dart';
import 'viewAllExpiredMembers.dart';
import 'resetMemberPassword.dart';

class AppDrawer extends StatelessWidget {
  final String docId;
  final String userRole;
  final String fullName;
  final String status;
  final int daysTillExpired;
  final DateTime expireDate;

  const AppDrawer({
    super.key,
    required this.docId,
    required this.userRole,
    required this.fullName,
    required this.status,
    required this.daysTillExpired,
    required this.expireDate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  fullName,
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Role: ${userRole[0].toUpperCase()}${userRole.substring(1)}',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (userRole == 'member') ...[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Main Menu'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => memberMainMenuPage(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.autorenew),
              title: Text('Renew Membership'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => RenewMembershipPage(docId, daysTillExpired, expireDate, userRole),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Alter Account'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MemberAlterAccount(docId),
                ));
              },
            ),
          ],
          if (userRole == 'employee') ...[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Main Menu'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EmployeeMainMenuPage(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.autorenew),
              title: Text('Renew Memberships'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => RenewMembershipPage(docId, daysTillExpired, expireDate, userRole),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Alter Account'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MemberAlterAccount(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('View All Members'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ViewAllMembershipEmployee(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('View All Expired Members'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ViewExpiredMembers(docId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('View All Banned Members'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ViewBannedMembers(docId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.disabled_by_default),
              title: Text('Ban Members'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BanMemberAccount(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text('Reset Member Password'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ResetMemberPassword(docId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red,),
              title: Text('Cancel Member Subscription'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CancelMemberAccount(docId),
                ));
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.map),
            title: Text('View Location on Map'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MyMap(docId),
              ));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginBase()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
