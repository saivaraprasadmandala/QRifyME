import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GiveFeedback extends StatefulWidget {
  final String title;
  final String description;

  const GiveFeedback({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<GiveFeedback> createState() => _GiveFeedbackState();
}

class _GiveFeedbackState extends State<GiveFeedback> {
  late final TextEditingController _feedback;
  String? currentUser = FirebaseAuth.instance.currentUser?.email;
  StreamSubscription<QuerySnapshot>? subscription;
  bool result = false;

  @override
  void initState() {
    super.initState();
    _feedback = TextEditingController();
    fetchUsersInLocation();
    subscribeToUsersInLocation();
  }

  @override
  void dispose() {
    subscription?.cancel();
    _feedback.dispose();
    super.dispose();
  }

  Future<void> fetchUsersInLocation() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference usersInLocationCollection =
            document.reference.collection('usersInLocation');
        QuerySnapshot<Map<String, dynamic>> usersInLocationSnapshot =
            await usersInLocationCollection.get()
                as QuerySnapshot<Map<String, dynamic>>;

        if (usersInLocationSnapshot.docs.isNotEmpty) {
          List<String> usersinlocation = usersInLocationSnapshot.docs
              .map((doc) => doc['email'] as String? ?? '')
              .toList();
          setState(() {
            result = usersinlocation.contains(currentUser);
          });
        }
      }
    }
  }

  void subscribeToUsersInLocation() {
    Query query = FirebaseFirestore.instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .limit(1);

    subscription = query.snapshots().listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        CollectionReference usersInLocationCollection =
            documentSnapshot.reference.collection('usersInLocation');
        usersInLocationCollection.snapshots().listen((usersSnapshot) {
          List<String> usersInLocation = usersSnapshot.docs
              .map((doc) => doc['email'] as String? ?? '')
              .toList();
          setState(() {
            result = usersInLocation.contains(currentUser);
          });
        });
      } else {
        setState(() {
          result = false;
        });
      }
    });
  }

  void createSubcollection() async {
    CollectionReference eventsRef =
        FirebaseFirestore.instance.collection('events');
    QuerySnapshot querySnapshot = await eventsRef
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      String documentId = documentSnapshot.id;
      DocumentReference documentRef = eventsRef.doc(documentId);
      CollectionReference subcollectionRef = documentRef.collection('feedback');

      await subcollectionRef.add({
        'email': currentUser,
        'feedback': _feedback.text.trim(),
      });
    }
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
                "YES",
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                createSubcollection();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Stack(
                        children: [
                          Lottie.asset(
                            'assets/animations/feedbackformsubmission.json',
                            reverse: true,
                            repeat: true,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
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
          "Feedback",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: result
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/feedback.json',
                        reverse: true,
                        repeat: true,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "You are inside the location, so you can submit the feedback form.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: TextField(
                              controller: _feedback,
                              cursorColor: Colors.deepPurple,
                              decoration: const InputDecoration(
                                hintText: 'Enter feedback',
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
                                  showAlertDialog(context, "Submit",
                                      "Do you want to submit feedback?");
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
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/nofeedback.json',
                      reverse: true,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Sorry, you are outside the event location. You can't submit feedback.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
