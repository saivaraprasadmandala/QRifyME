import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/home/loading.dart';

class Notifications extends StatefulWidget {
  final String title;
  final String description;
  const Notifications({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late final TextEditingController _name;
  late final TextEditingController _message;
  String sendToUsersInlocation = 'false';

  List<String> usersInLocation = [];
  List<String> registeredUsers = [];

  @override
  void initState() {
    _name = TextEditingController();
    _message = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> createSubcollection() async {
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
      CollectionReference subcollectionRef =
          documentRef.collection('notifications');
      String name = _name.text.trim();
      String message = _message.text.trim();
      await subcollectionRef.add({
        'name': name,
        'message': message,
        'sendToUsersInlocation': sendToUsersInlocation,
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

  Future<void> sendNotificationToUsersInLocation() async {
    sendToUsersInlocation = 'true';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Are you sure you want to send the notification to users present in event location?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
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
                'Send',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                createSubcollection();
                Navigator.of(context).pop();
                showAlertDialog(
                    context, 'Success', 'Notification sent successfully.');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendNotificationsToAllUsers() async {
    sendToUsersInlocation = 'false';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Are you sure you want to send the notifications to all users?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
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
                'Send',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                createSubcollection();
                Navigator.of(context).pop();

                showAlertDialog(
                    context, 'Success', 'Notification sent successfully.');
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
          "Notifications",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          const Text(
            "send notifications to your attendees here",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
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
                  controller: _name,
                  cursorColor: Colors.deepPurple,
                  decoration: const InputDecoration(
                    hintText: 'Title of notification',
                    border: InputBorder.none,
                  ),
                ),
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
                  controller: _message,
                  cursorColor: Colors.deepPurple,
                  decoration: const InputDecoration(
                    hintText: 'Message',
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
            children: [
              SizedBox(
                height: 50,
                width: 350,
                child: ElevatedButton(
                    onPressed: () {
                      final String name = _name.text.trim();
                      final String message = _message.text.trim();
                      if (name.isNotEmpty && message.isNotEmpty) {
                        sendNotificationsToAllUsers();
                      } else if (name.isEmpty) {
                        showAlertDialog(context, 'Invalid Input',
                            'please enter title of notification');
                      } else if (message.isEmpty) {
                        showAlertDialog(context, 'Invalid Input',
                            'please enter message of notification');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Send to all users",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              SizedBox(
                height: 50,
                width: 350,
                child: ElevatedButton(
                    onPressed: () {
                      final String name = _name.text.trim();
                      final String message = _message.text.trim();
                      if (name.isNotEmpty && message.isNotEmpty) {
                        sendNotificationToUsersInLocation();
                      } else if (name.isEmpty) {
                        showAlertDialog(context, 'Invalid Input',
                            'please enter title of notification');
                      } else if (message.isEmpty) {
                        showAlertDialog(context, 'Invalid Input',
                            'please enter message of notification');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Send to users who are inside location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('title', isEqualTo: widget.title)
                  .where('description', isEqualTo: widget.description)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }

                if (snapshot.hasError) {
                  return Scaffold(
                    backgroundColor: Colors.grey[300],
                    body: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Scaffold(
                    backgroundColor: Colors.grey[300],
                    body: const Text('No events found.'),
                  );
                }

                final eventDoc = snapshot.data!.docs.first;
                final notificationsCollection =
                    eventDoc.reference.collection('notifications');

                return StreamBuilder<QuerySnapshot>(
                  stream: notificationsCollection.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loading();
                    }

                    if (snapshot.hasError) {
                      return Scaffold(
                        backgroundColor: Colors.grey[300],
                        body: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Scaffold(
                        backgroundColor: Colors.grey[300],
                        body: const Center(
                            child: Text('No notifications found.')),
                      );
                    }

                    final notifications = snapshot.data!.docs.map((doc) {
                      final name = doc['name'].toString();
                      final message = doc['message'].toString();
                      final sendToUsersInLocation =
                          doc['sendToUsersInlocation'].toString();
                      return '$name - $message - $sendToUsersInLocation';
                    }).toList();

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (BuildContext context, int index) {
                        String notification = notifications[index];
                        String name = notification.split(' - ')[0];
                        String message = notification.split(' - ')[1];
                        String condition = notification.split(' - ')[2];

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Title : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(name),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Message : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(message),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Notification sent to users in location : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(condition),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
