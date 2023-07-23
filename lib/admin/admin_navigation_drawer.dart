// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/admin/admin_events.dart';
import 'package:app/portals/forgot_password.dart';
import 'package:app/portals/login_view.dart';
import 'package:app/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminNavigationDrawer extends StatefulWidget {
  const AdminNavigationDrawer({super.key});

  @override
  State<AdminNavigationDrawer> createState() => _AdminNavigationDrawerState();
}

class _AdminNavigationDrawerState extends State<AdminNavigationDrawer> {
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => const LoginView(),
      ),
    );
  }

  void showLogoutAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'NO',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text(
                  'YES',
                  style: TextStyle(color: Colors.deepPurple),
                ),
                onPressed: () {
                  logout();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  "QRify ME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => const Profile(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event_available,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "Hosted Events",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => const AdminEvents(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "Change Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => const ForgotPasswordView(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                showLogoutAlert(context, "Logout", "Are you going to logout");
              },
            )
          ],
        ),
      ),
    );
  }
}
