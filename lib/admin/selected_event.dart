import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectedEvent extends StatefulWidget {
  final String title;
  final String description;

  const SelectedEvent({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<SelectedEvent> createState() => _SelectedEventState();
}

class _SelectedEventState extends State<SelectedEvent> {
  List<String> registeredUsers = [];
  List<String> usersInLocation = [];
  List<String> usersEmail = [];
  bool showRegisteredUsers = false;
  bool showUsersInLocation = false;
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Future<void> fetchRegisteredUsers() async {
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
            await registeredUsersCollection.get()
                as QuerySnapshot<Map<String, dynamic>>;

        if (registeredUsersSnapshot.docs.isNotEmpty) {
          List<String> registeredusers = registeredUsersSnapshot.docs
              .map((doc) => doc['email'] as String? ?? '')
              .toList();
          setState(() {
            registeredUsers = registeredusers;
          });
        } else {
          const Text('No registered users found in this event.');
        }
      }
    } else {
      const Text('No events found.');
    }
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
            usersInLocation = usersinlocation;
          });
        } else {
          const Text('No registered users found in this event.');
        }
      }
    } else {
      const Text('No events found.');
    }
  }

  Future<void> blockUsers() async {
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
            await registeredUsersCollection.get()
                as QuerySnapshot<Map<String, dynamic>>;

        if (registeredUsersSnapshot.docs.isNotEmpty) {
          List<Map<String, String>> toBlockUsers = registeredUsersSnapshot.docs
              .map((doc) => {
                    'email': doc['email'] as String? ?? '',
                    'time': doc['time'] as String? ?? '',
                  })
              .toList();

          for (Map<String, String> user in toBlockUsers) {
            if (user['time'] == '0') {
              QuerySnapshot<Map<String, dynamic>> userSnapshot =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: user['email'])
                      .get();

              if (userSnapshot.docs.isNotEmpty) {
                DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
                    userSnapshot.docs[0];
                int currentBlockCount =
                    userDocSnapshot.data()?['blockCount'] ?? '0';

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDocSnapshot.id)
                    .update({'blockCount': currentBlockCount + 1});
              }
            }
          }

          setState(() {
            toBlockUsers = toBlockUsers;
          });
        } else {
          const Text('No registered users found in this event.');
        }
      }
    } else {
      const Text('No events found.');
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
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                blockUsers();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchRegisteredUsers();
    fetchUsersInLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Selected Event",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "See your attendees here",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showUsersInLocation = true;
                          });
                          fetchUsersInLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Get Users in location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showUsersInLocation)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Serial No.')),
                          DataColumn(label: Text('Email')),
                        ],
                        rows: List<DataRow>.generate(
                          usersInLocation.length,
                          (index) => DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(usersInLocation[index])),
                          ]),
                        ),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showRegisteredUsers = true;
                          });
                          fetchRegisteredUsers();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Get All Users",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showRegisteredUsers)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Serial No.')),
                          DataColumn(label: Text('Email')),
                        ],
                        rows: List<DataRow>.generate(
                          registeredUsers.length,
                          (index) => DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(registeredUsers[index])),
                          ]),
                        ),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          showAlertDialog(context, "Block users",
                              "By clicking this button you are blocking the users to who have not attended for the event.");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Block users",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
