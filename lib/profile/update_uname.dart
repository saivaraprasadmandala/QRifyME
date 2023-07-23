import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app/portals/login_view.dart';

class UpdateUname extends StatefulWidget {
  const UpdateUname({super.key});

  @override
  State<UpdateUname> createState() => _UpdateUnameState();
}

class _UpdateUnameState extends State<UpdateUname> {
  late final TextEditingController _uname;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showUnameAlert(BuildContext context, String title, String message) {
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
              onPressed: () async {
                final uname = _uname.text.trim();
                if (uname.isNotEmpty) {
                  QuerySnapshot snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: userEmail)
                      .get();
                  // ignore: avoid_function_literals_in_foreach_calls
                  snapshot.docs.forEach((DocumentSnapshot doc) async {
                    await doc.reference.update({
                      'uname': uname,
                    });
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const LoginView();
                    }),
                  );
                } else {
                  showAlertDialog(context, "Invalid", "error");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _uname = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _uname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Username'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Lottie.asset(
                'assets/animations/usernameUpdate.json',
                reverse: true,
                repeat: true,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _uname,
                      cursorColor: Colors.deepPurple,
                      decoration: const InputDecoration(
                        hintText: 'enter username',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      showUnameAlert(context, "update username",
                          "do you really want to update your username");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "UPDATE USERNAME",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
