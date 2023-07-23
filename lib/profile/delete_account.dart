import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app/appIntro/app_intro.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  late final TextEditingController _email;
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

  void showDeleteDialog(BuildContext context, String title, String message) {
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
                Navigator.of(context).pop();
                deleteInAuth();
                deleteRegisteredEvents();
                deleteInFirestore();
                deleteRegisteredUsers();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AppIntro(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteInFirestore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get()
        .then(
      (QuerySnapshot snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      },
    );
  }

  Future<void> deleteInAuth() async {
    await FirebaseAuth.instance.currentUser?.delete();
  }

  Future<void> deleteRegisteredEvents() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference registeredEventsCollection =
            document.reference.collection('registeredEvents');

        QuerySnapshot<Map<String, dynamic>> registeredEventsSnapshot =
            await registeredEventsCollection.get()
                as QuerySnapshot<Map<String, dynamic>>;

        for (QueryDocumentSnapshot<Map<String, dynamic>> eventDoc
            in registeredEventsSnapshot.docs) {
          await eventDoc.reference.delete();
        }
      }
    }
  }

  Future<void> deleteRegisteredUsers() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Query registeredEventsQuery = document.reference
            .collection('registeredUsers')
            .where('email', isEqualTo: userEmail);

        QuerySnapshot<Map<String, dynamic>> registeredEventsSnapshot =
            await registeredEventsQuery.get()
                as QuerySnapshot<Map<String, dynamic>>;

        for (QueryDocumentSnapshot<Map<String, dynamic>> eventDoc
            in registeredEventsSnapshot.docs) {
          await eventDoc.reference.delete();
        }
      }
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Deletion'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/deleteUser.json',
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
                    controller: _email,
                    cursorColor: Colors.deepPurple,
                    decoration: const InputDecoration(
                      hintText: 'enter email',
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
                  onPressed: () async {
                    final email = _email.text.trim();
                    if (email == userEmail) {
                      showDeleteDialog(context, "Account Deletion Confirmation",
                          "Do you really want to delete your account?");
                    } else if (email != userEmail) {
                      showAlertDialog(
                          context, "Invalid", "Enter your registered email");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "DELETE ACCOUNT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
