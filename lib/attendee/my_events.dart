import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app/attendee/attendee_navigation.dart';
import 'package:app/attendee/deregister.dart';
import 'package:app/home/loading.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({
    Key? key,
  }) : super(key: key);

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  List<Map<String, dynamic>> registeredEvents = [];
  String? currUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<List<Map<String, dynamic>>> fetchUserEvents() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: currUserEmail)
        .get();

    List<Map<String, dynamic>> events = [];

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot<Map<String, dynamic>>> documents =
          querySnapshot.docs;

      for (var document in documents) {
        QuerySnapshot<Map<String, dynamic>> registeredEventsSnapshot =
            await document.reference.collection('registeredEvents').get();

        if (registeredEventsSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> userEvents =
              registeredEventsSnapshot.docs.map((doc) => doc.data()).toList();
          events.addAll(userEvents);
        }
      }
    }

    return events;
  }

  @override
  void initState() {
    super.initState();
    // fetchUserEvents(); // Remove this line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registered Events",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the events to be fetched, show a loading indicator
            return const Loading();
          } else if (snapshot.hasError) {
            // If an error occurs during fetching, display an error message
            return const Center(
              child: Text(
                'Failed to fetch events.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            );
          } else {
            registeredEvents = snapshot.data ?? [];

            if (registeredEvents.isEmpty) {
              // If there are no registered events, display a message
              return const Center(
                child: Text(
                  'No registered events.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              );
            } else {
              // If there are registered events, display them
              return Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "You can see all your registered events here",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: registeredEvents.length,
                      itemBuilder: (context, index) {
                        final eventData = registeredEvents[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListTile(
                                title: Text(
                                  '${eventData['title']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('${eventData['description']}'),
                              ),
                            ),
                            QrImageView(
                              data: eventData['qrData'],
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 200,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      String eventTitle = eventData['title'];
                                      String eventDescription =
                                          eventData['description'];

                                      FirebaseFirestore.instance
                                          .collection("events")
                                          .where("title", isEqualTo: eventTitle)
                                          .where('description',
                                              isEqualTo: eventDescription)
                                          .get()
                                          .then((querySnapshot) {
                                        if (querySnapshot.docs.isNotEmpty) {
                                          final eventsData = querySnapshot.docs;
                                          final event = eventsData[0].data();

                                          final title = event['title'];
                                          final description =
                                              event['description'];
                                          final email =
                                              currUserEmail.toString();
                                          final timeStamp = event['timeStamp'];

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return AttendeeNavigation(
                                                  title: title,
                                                  description: description,
                                                  email: email,
                                                  timeStamp: timeStamp,
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Event Not Found'),
                                              content: const Text(
                                                  'The selected event could not be found.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "SELECT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Not attending the Event ? ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            String eventTitle =
                                                eventData['title'];
                                            String eventDescription =
                                                eventData['description'];

                                            FirebaseFirestore.instance
                                                .collection("events")
                                                .where("title",
                                                    isEqualTo: eventTitle)
                                                .where('description',
                                                    isEqualTo: eventDescription)
                                                .get()
                                                .then((querySnapshot) {
                                              if (querySnapshot
                                                  .docs.isNotEmpty) {
                                                final eventsData =
                                                    querySnapshot.docs;
                                                final event =
                                                    eventsData[0].data();

                                                final title = event['title'];
                                                final description =
                                                    event['description'];
                                                final email =
                                                    currUserEmail.toString();
                                                final timeStamp =
                                                    event['timeStamp'];

                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (BuildContext context) {
                                                      return Deregister(
                                                        title: title,
                                                        description:
                                                            description,
                                                        email: email,
                                                        timeStamp: timeStamp,
                                                      );
                                                    },
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                          child: const Text(
                                            'Click here',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          )),
                                    ]),
                              ],
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
