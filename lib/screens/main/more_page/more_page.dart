import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../utils/colors.dart';
import '../../login/login_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: AppColors.secondaryColor),
            title: Text('Profile', style: TextStyle(color: Colors.black)),
            onTap: () {
              // TODO: Navigate to Profile page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.secondaryColor),
            title: Text('Settings', style: TextStyle(color: Colors.black)),
            onTap: () {
              // TODO: Navigate to Settings page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help_outline, color: AppColors.secondaryColor),
            title: Text(
              'Help & Support',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // TODO: Navigate to Help page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.secondaryColor),
            title: Text('Logout', style: TextStyle(color: Colors.black)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
