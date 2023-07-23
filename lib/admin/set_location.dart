// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as location;

class SetLocation extends StatefulWidget {
  final String documentId;

  const SetLocation({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  double _eventRadius = 0.0;
  final TextEditingController _searchController = TextEditingController();
  final location.Location _location = location.Location();

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // showAlertDialog(context, "Set Event Location",
    //     "Using searchbar findout your event location and pinpoint exact location.\n Using slider given below set event radius.\n If the attendee leaves this circle then he will be out of the location.");
  }

  Future<void> _getCurrentLocation() async {
    try {
      location.LocationData? locationData = await _location.getLocation();
      if (locationData != null) {
        final latitude = locationData.latitude!;
        final longitude = locationData.longitude!;
        setState(() {
          _selectedLocation = LatLng(latitude, longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(latitude, longitude),
            15,
          ),
        );
      }
    } catch (e) {
      //print('Error getting current location: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Set Event Location",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onTap: (position) {
              setState(() {
                _selectedLocation = position;
              });
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
            circles: _selectedLocation != null
                ? {
                    Circle(
                      circleId: const CircleId('eventRadius'),
                      center: _selectedLocation!,
                      radius: _eventRadius,
                      fillColor: Colors.blue.withOpacity(0.2),
                      strokeColor: Colors.blue,
                    ),
                  }
                : {},
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        cursorColor: Colors.deepPurple,
                        decoration: const InputDecoration(
                          hintText: 'Search for a location',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final query = _searchController.text;
                      if (query.isNotEmpty) {
                        List<Location> locations =
                            await locationFromAddress(query);
                        if (locations.isNotEmpty) {
                          final location = locations.first;
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(location.latitude, location.longitude),
                              15,
                            ),
                          );
                          setState(() {
                            _selectedLocation =
                                LatLng(location.latitude, location.longitude);
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 100,
            child: Slider(
              min: 0,
              max: 500,
              value: _eventRadius,
              activeColor: Colors.deepPurple,
              inactiveColor: const Color.fromARGB(255, 130, 98, 185),
              onChanged: (value) {
                setState(() {
                  _eventRadius = value;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: FloatingActionButton(
          onPressed: () async {
            if (_selectedLocation != null) {
              final latitude = _selectedLocation!.latitude;
              final longitude = _selectedLocation!.longitude;
              final range = _eventRadius;

              await FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.documentId)
                  .update({
                'latitude': latitude,
                'longitude': longitude,
                'range': range,
              });
            }
            Navigator.pop(context);
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(
            Icons.check,
          ),
        ),
      ),
    );
  }
}
