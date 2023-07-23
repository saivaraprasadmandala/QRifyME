// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/attendee/attendee_navigation_drawer.dart';
import 'package:app/home/loading.dart';
import '/attendee/attendee_navigation.dart';
import '/attendee/event_info.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  String title = '';
  String description = '';
  String email = '';
  String timeStamp = '';

  List<String> registeredUsers = [];
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final CollectionReference<Map<String, dynamic>> _reference =
      FirebaseFirestore.instance.collection("events");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Events",
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      drawer: const AttendeeNavigationDrawer(),
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "There are many Events for you",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              " Register and enjoy the Event ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _reference.get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return Text("Some error has occurred: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Events found."));
                }

                List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                    snapshot.data!.docs;

                List<Map<String, dynamic>> items = documents
                    .map((e) {
                      final eventData = e.data();
                      if (eventData == null) {
                        // print("Document data is null");
                        return null;
                      }

                      final startDate = eventData['startDate'] != null
                          ? (eventData['startDate'] as Timestamp)
                              .toDate()
                              .toString()
                          : '';
                      final endDate = eventData['endDate'] != null
                          ? (eventData['endDate'] as Timestamp)
                              .toDate()
                              .toString()
                          : '';

                      return {
                        'title': eventData['title'] as String? ?? '',
                        'description':
                            eventData['description'] as String? ?? '',
                        'instructions':
                            eventData['instructions'] as String? ?? '',
                        'capacity': eventData['capacity'] as String? ?? '',
                        'startDate': startDate,
                        'endDate': endDate,
                        'startTime': eventData['startTime'] as String? ?? '',
                        'endTime': eventData['endTime'] as String? ?? '',
                        'location': eventData['location'] as String? ?? '',
                        'mobile': eventData['mobile'] as String? ?? '',
                        'email': eventData['email'] as String? ?? '',
                        'host': eventData['host'] as String? ?? '',
                        'timeStamp': eventData['timeStamp'] as String? ?? '',
                        'days': eventData['days'] as List<dynamic>? ?? [],
                      };
                    })
                    .where((element) => element != null)
                    .toList()
                    .cast<Map<String, dynamic>>();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> thisItem = items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 7,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      "${thisItem['title']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                            text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            const TextSpan(
                                              text: "DESCRIPTION : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  "${thisItem['description']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        )),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                            text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            const TextSpan(
                                              text: "INSTRUCTIONS : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  "${thisItem['instructions']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        )),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                            text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            const TextSpan(
                                              text: "LOCATION : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "${thisItem['location']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        )),
                                      )
                                    ],
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 300,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventInfo(
                                                    title: thisItem['title'],
                                                    description:
                                                        thisItem['description'],
                                                    instructions: thisItem[
                                                        'instructions'],
                                                    capacity:
                                                        thisItem['capacity'],
                                                    location:
                                                        thisItem['location'],
                                                    mobile: thisItem['mobile'],
                                                    email: thisItem['email'],
                                                    host: thisItem['host'],
                                                    timeStamp:
                                                        thisItem['timeStamp'],
                                                    days: thisItem['days'],
                                                    startTime:
                                                        thisItem['startTime'],
                                                    endTime:
                                                        thisItem['endTime'],
                                                    startDate:
                                                        thisItem['startDate'],
                                                    endDate:
                                                        thisItem['endDate'],
                                                  ),
                                                ));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Text(
                                                "More Info",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Already Registered ? ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          QuerySnapshot<Map<String, dynamic>>
                                              querySnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('events')
                                                  .where('title',
                                                      isEqualTo:
                                                          thisItem['title'])
                                                  .where('description',
                                                      isEqualTo: thisItem[
                                                          'description'])
                                                  .get();

                                          if (querySnapshot.docs.isNotEmpty) {
                                            for (QueryDocumentSnapshot<
                                                    Map<String,
                                                        dynamic>> document
                                                in querySnapshot.docs) {
                                              CollectionReference
                                                  registeredUsersCollection =
                                                  document.reference.collection(
                                                      'registeredUsers');
                                              QuerySnapshot<
                                                      Map<String, dynamic>>
                                                  registeredUsersSnapshot =
                                                  await registeredUsersCollection
                                                          .get()
                                                      as QuerySnapshot<
                                                          Map<String, dynamic>>;

                                              if (registeredUsersSnapshot
                                                  .docs.isNotEmpty) {
                                                List<String> registeredusers =
                                                    registeredUsersSnapshot.docs
                                                        .map((doc) =>
                                                            doc['email']
                                                                as String? ??
                                                            '')
                                                        .toList();
                                                setState(() {
                                                  registeredUsers =
                                                      registeredusers;
                                                });
                                              }
                                            }
                                          }
                                          if (registeredUsers
                                              .contains(currentUser)) {
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  AttendeeNavigation(
                                                title: thisItem['title'],
                                                description:
                                                    thisItem['description'],
                                                email: currentUser.toString(),
                                                timeStamp:
                                                    thisItem['timeStamp'],
                                              ),
                                            ));
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showAlertDialog(
                                                context,
                                                "Not registered",
                                                "You haven't registered for this event please register");
                                          }
                                        },
                                        child: const Text(
                                          "go to my event",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
