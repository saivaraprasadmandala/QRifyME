import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/home/loading.dart';

class ReceiveNotifications extends StatefulWidget {
  final String title;
  final String description;

  const ReceiveNotifications({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<ReceiveNotifications> createState() => _ReceiveNotificationsState();
}

class _ReceiveNotificationsState extends State<ReceiveNotifications> {
  List<String> usersInLocation = [];
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  StreamSubscription<QuerySnapshot<Object?>>? _notificationInfo;

  Future<void> fetchUsersInLocation() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (mounted) {
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in querySnapshot.docs) {
          CollectionReference usersInLocationCollection =
              document.reference.collection('usersInLocation');
          QuerySnapshot<Map<String, dynamic>> usersInLocationSnapshot =
              await usersInLocationCollection.get()
                  as QuerySnapshot<Map<String, dynamic>>;

          if (mounted) {
            if (usersInLocationSnapshot.docs.isNotEmpty) {
              List<String> usersinlocation = usersInLocationSnapshot.docs
                  .map((doc) => doc['email'] as String? ?? '')
                  .toList();
              if (mounted) {
                setState(() {
                  usersInLocation = usersinlocation;
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  usersInLocation = [];
                });
              }
              const Text('No registered users found in this event.');
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            usersInLocation = [];
          });
        }
        const Text('No events found.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsersInLocation();
  }

  @override
  void dispose() {
    _notificationInfo?.cancel();
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchUsersInLocation();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Click on Refresh to get correct Notification",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
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

                        if (usersInLocation.contains(currentUser)) {
                          return ListTile(
                            title: Text(name),
                            subtitle: Text(message),
                          );
                        } else if (condition == 'false') {
                          return ListTile(
                            title: Text(name),
                            subtitle: Text(message),
                          );
                        }
                        return Container();
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
