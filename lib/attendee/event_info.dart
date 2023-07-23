// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/attendee/attendee_navigation.dart';
import 'event_registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventInfo extends StatefulWidget {
  final String title;
  final String description;
  final String instructions;
  final String capacity;
  final String location;
  final String mobile;
  final String email;
  final String host;
  final String timeStamp;
  final List<dynamic> days;
  final String startTime;
  final String endTime;
  final String startDate;
  final String endDate;

  const EventInfo({
    super.key,
    required this.title,
    required this.description,
    required this.instructions,
    required this.capacity,
    required this.location,
    required this.mobile,
    required this.email,
    required this.host,
    required this.timeStamp,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<EventInfo> createState() => _EventInfoState();
}

class _EventInfoState extends State<EventInfo> {
  late String? email = FirebaseAuth.instance.currentUser?.email;
  int capacity = 0;
  int blockCount = 0;

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
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                if (email != null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return AttendeeNavigation(
                        title: widget.title,
                        description: widget.description,
                        email: email.toString(),
                        timeStamp: widget.timeStamp,
                      );
                    }),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showRegistrationsFullDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'Close',
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

  void storeRegisteredEvents() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    CollectionReference eventsRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot eventsDocumentSnapshot =
        await eventsRef.where('email', isEqualTo: email).get();

    if (eventsDocumentSnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = eventsDocumentSnapshot.docs.first;
      String documentId = documentSnapshot.id;
      DocumentReference documentRef = eventsRef.doc(documentId);
      CollectionReference subcollectionRef =
          documentRef.collection('registeredEvents');
      String qrData = email! + widget.timeStamp;
      await subcollectionRef.add({
        'title': widget.title,
        'description': widget.description,
        'qrData': qrData,
      });
    }
  }

  void getBlockCount() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await usersRef.where('email', isEqualTo: userEmail).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
      blockCount = documentSnapshot['blockCount'];
    }
  }

  Future<void> registerForEvent() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    CollectionReference eventsRef =
        FirebaseFirestore.instance.collection('events');
    QuerySnapshot querySnapshot = await eventsRef
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
      String capacityString = documentSnapshot['capacity'];
      int numOfRegisteredUsers = documentSnapshot['numOfRegisteredUsers'];
      capacity = int.parse(capacityString);

      if (capacity > numOfRegisteredUsers) {
        if (blockCount < 3) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          String documentId = documentSnapshot.id;
          DocumentReference documentRef = eventsRef.doc(documentId);
          CollectionReference subcollectionRef =
              documentRef.collection('registeredUsers');

          QuerySnapshot registeredUsersSnapshot =
              await subcollectionRef.where('email', isEqualTo: email).get();

          if (registeredUsersSnapshot.docs.isNotEmpty) {
            showAlertDialog(context, 'Already Registered',
                'You have already registered for this event.');
          } else {
            storeRegisteredEvents();
            await subcollectionRef.add({
              'email': email,
              'time': "0",
            });
            // ignore: await_only_futures
            await FirebaseFirestore.instance
                .collection('events')
                .where('title', isEqualTo: widget.title)
                .where('description', isEqualTo: widget.description)
                .get()
                .then(
              (QuerySnapshot snapshot) {
                for (var doc in snapshot.docs) {
                  int updatedValue = numOfRegisteredUsers + 1;

                  FirebaseFirestore.instance
                      .collection('events')
                      .doc(doc.id)
                      .update({
                    'numOfRegisteredUsers': updatedValue,
                  });
                }
              },
            );

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return EventRegistration(
                    title: widget.title,
                    description: widget.description,
                  );
                },
              ),
            );
          }
        } else {
          showRegistrationsFullDialog(
              context, "Can't register", "you are blocked");
        }
      } else {
        showRegistrationsFullDialog(context, "Can't register",
            "Event capacity is full so you can't register for this event.");
      }
      //print('Capacity: $capacity');
    } else {
      //print('No documents found with matching title and description.');
    }
  }

  @override
  void initState() {
    super.initState();
    getBlockCount();
  }

  @override
  Widget build(BuildContext context) {
    String sdate =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.startDate));
    sdate.split(" ");

    String edate =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.endDate));
    sdate.split(" ");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Events",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "What are you waiting for...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Text(
                " Goahead and register for the event ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'DESCRIPTION : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.description),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'INSTRUCTIONS : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.instructions),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'EVENT CAPACITY : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.capacity),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'EVENT STARTS ON : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: sdate),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'EVENT ENDS ON : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: edate),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'EVENT STARTS AT : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.startTime),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'EVENT ENDS AT : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.endTime),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: List.generate(widget.days.length, (index) {
                            var day = widget.days[index];
                            var num = index + 1;
                            return ListTile(
                              title: Text(
                                'Day: $num',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(' $day'),
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'LOCATION : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.location),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'CONTACT DETAILS : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            "${widget.mobile} , ${widget.email}"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'NAME OF THE HOST : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.host),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 50,
                                width: 300,
                                child: ElevatedButton(
                                    onPressed: registerForEvent,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "REGISTER",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
