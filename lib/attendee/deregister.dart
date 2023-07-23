import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Deregister extends StatefulWidget {
  final String title;
  final String description;
  final String email;
  final String timeStamp;
  const Deregister({
    Key? key,
    required this.title,
    required this.description,
    required this.email,
    required this.timeStamp,
  }) : super(key: key);

  @override
  State<Deregister> createState() => _DeregisterState();
}

class _DeregisterState extends State<Deregister> {
  late final TextEditingController _email;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> deleteRegisteredUser() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference registeredUsersCollection =
            document.reference.collection('registeredUsers');

        QuerySnapshot<Map<String, dynamic>> registeredUsersSnapshot =
            await registeredUsersCollection
                .where('email', isEqualTo: userEmail)
                .get() as QuerySnapshot<Map<String, dynamic>>;

        if (registeredUsersSnapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> registeredUser
              in registeredUsersSnapshot.docs) {
            await registeredUser.reference.delete();

            // Show a success message or perform any other necessary actions
            //print('Document deleted successfully.');
          }
        }
      }
    }
  }

  Future<void> deleteQrdata() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference qrDataCollection =
            document.reference.collection('qrData');

        String datainqr = userEmail! + widget.timeStamp;
        QuerySnapshot<Map<String, dynamic>> qrDataSnapshot =
            await qrDataCollection.where('qrData', isEqualTo: datainqr).get()
                as QuerySnapshot<Map<String, dynamic>>;

        if (qrDataSnapshot.docs.isNotEmpty) {
          // ignore: non_constant_identifier_names
          for (QueryDocumentSnapshot<Map<String, dynamic>> QrData
              in qrDataSnapshot.docs) {
            await QrData.reference.delete();

            // Show a success message or perform any other necessary actions
            //print('Document deleted successfully.');
          }
        }
      }
    }
  }

  Future<void> deleteMyEvent() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference qrDataCollection =
            document.reference.collection('registeredEvents');

        QuerySnapshot<Map<String, dynamic>> qrDataSnapshot =
            await qrDataCollection
                .where('title', isEqualTo: widget.title)
                .where('description', isEqualTo: widget.description)
                .get() as QuerySnapshot<Map<String, dynamic>>;

        if (qrDataSnapshot.docs.isNotEmpty) {
          // ignore: non_constant_identifier_names
          for (QueryDocumentSnapshot<Map<String, dynamic>> QrData
              in qrDataSnapshot.docs) {
            await QrData.reference.delete();

            // Show a success message or perform any other necessary actions
            //print('Document deleted successfully.');
          }
        }
      }
    }
  }

  Future<void> decrementCount() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot registeredUSersSnapshot = querySnapshot.docs[0];
      int numOfRegisteredUsers =
          registeredUSersSnapshot['numOfRegisteredUsers'];

      // ignore: await_only_futures
      await FirebaseFirestore.instance
          .collection('events')
          .where('title', isEqualTo: widget.title)
          .where('description', isEqualTo: widget.description)
          .get()
          .then(
        (QuerySnapshot snapshot) {
          for (var doc in snapshot.docs) {
            int updatedValue = numOfRegisteredUsers - 1;

            FirebaseFirestore.instance.collection('events').doc(doc.id).update(
              {
                'numOfRegisteredUsers': updatedValue,
              },
            );
          }
        },
      );
    }
  }

  void showSuccessDialog(BuildContext context, String title, String message) {
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
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteRegisteredUser();
                deleteQrdata();
                deleteMyEvent();
                decrementCount();
              },
            ),
          ],
        );
      },
    );
  }

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
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cancel event registration",
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Lottie.asset(
                'assets/animations/cancellation.json',
                reverse: true,
                repeat: true,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Enter your registered email to cancel event registration.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
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
                        hintText: 'Enter email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        onPressed: () {
                          final email = _email.text.trim();
                          if (email == userEmail) {
                            _email.clear();
                            showSuccessDialog(context, "Event Cancellation",
                                "Do you really want to cancel event registration ?");
                          } else {
                            showAlertDialog(context, "Invalid email",
                                "Please enter your registered email");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "SUBMIT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
