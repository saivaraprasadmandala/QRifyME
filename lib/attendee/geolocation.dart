// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:app/home/loading.dart';

class GeotrackPage extends StatefulWidget {
  final String title;
  final String description;

  const GeotrackPage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<GeotrackPage> createState() => _GeotrackPageState();
}

class _GeotrackPageState extends State<GeotrackPage> {
  Position _eventLocation = const Position(
    latitude: 0,
    longitude: 0,
    timestamp: null,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  Position? _userLocation;
  double? _distance;
  late StreamSubscription<Position> _locationSubscription;
  bool _insideEventLocation = false;
  double? rangeOfLocation;

  String? email = '';

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("events");

  Future<void> getLocationCoordinates() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _reference
          .where('title', isEqualTo: widget.title)
          .where('description', isEqualTo: widget.description)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            snapshot.docs.first;
        Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null) {
          double latitude = data['latitude'];
          double longitude = data['longitude'];
          double range = data['range'];

          // Update the event location and range
          _eventLocation = Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: null,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
          );
          rangeOfLocation = range;
        } else {
          // Handle case when data is null
        }
      } else {
        // Handle case when there are no documents matching the conditions
      }
    } catch (e) {
      // Handle any errors that occur during fetching data
      //print('Error: $e');
    }
  }

  Future<void> _getLocationPermissionAndListen() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await _requestLocationPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startListening();
    }
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
      CollectionReference subcollectionRef =
          documentRef.collection('usersInLocation');

      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      QuerySnapshot userSnapshot = await subcollectionRef
          .where('email', isEqualTo: currentUserEmail)
          .get();
      if (userSnapshot.docs.isEmpty) {
        await subcollectionRef.add({
          'email': currentUserEmail,
        });
      }
    }
  }

  void removeUserFromSubcollection() async {
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
          documentRef.collection('usersInLocation');

      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      QuerySnapshot userSnapshot = await subcollectionRef
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDocument = userSnapshot.docs.first;
        String userDocumentId = userDocument.id;
        await subcollectionRef.doc(userDocumentId).delete();
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      //print('Permission denied');
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startListening();
    }
  }

  void _startListening() {
    _locationSubscription =
        Geolocator.getPositionStream().listen(_onLocationUpdate);
  }

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    _getLocationPermissionAndListen();
    getLocationCoordinates();
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription.cancel();
  }

  void _onLocationUpdate(Position? position) {
    if (position != null) {
      setState(() {
        _userLocation = position;
        _distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _eventLocation.latitude,
          _eventLocation.longitude,
        );
        _insideEventLocation = (_distance != null &&
            rangeOfLocation != null &&
            _distance! <= rangeOfLocation!);

        if (_insideEventLocation) {
          createSubcollection();
        } else {
          removeUserFromSubcollection();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int? distance = _distance?.toInt();
    bool isLoading = _userLocation == null && _insideEventLocation == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Tracker",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_insideEventLocation != null && _insideEventLocation)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Yeah..!!!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "you are inside event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const Text(
                            "location",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "enjoy your event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'You are inside event location.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Lottie.asset(
                            'assets/animations/insideLocation.json',
                            fit: BoxFit.cover,
                          )
                        ],
                      ),
                    ),
                  if (!_insideEventLocation && _distance != null)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Oh NO!!!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "you are not in event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const Text(
                            "location",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "goto event location to get event related updates and enjoy the event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'You are $distance meters away from the event location.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Lottie.asset(
                            'assets/animations/outsideLocation.json',
                            fit: BoxFit.cover,
                          )
                        ],
                      ),
                    ),
                  if (_userLocation == null && _insideEventLocation == null)
                    const Text('Location data not available'),
                ],
              ),
            ),
            // Circular indicator
            if (isLoading) const Loading()
          ],
        ),
      ),
    );
  }
}
