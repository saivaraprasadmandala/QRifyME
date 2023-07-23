import 'package:flutter/material.dart';
import 'package:app/attendee/geolocation.dart';
import 'package:app/attendee/qr_storing.dart';
import 'package:app/attendee/give_feedback.dart';
import 'package:app/attendee/receive_notifications.dart';

class AttendeeNavigation extends StatefulWidget {
  final String title;
  final String description;
  final String email;
  final String timeStamp;

  const AttendeeNavigation({
    Key? key,
    required this.title,
    required this.description,
    required this.email,
    required this.timeStamp,
  }) : super(key: key);

  @override
  State<AttendeeNavigation> createState() => _AttendeeNavigationState();
}

class _AttendeeNavigationState extends State<AttendeeNavigation> {
  int _selectedIndex = 0;
  bool isFormEnabled = false;

  void _navigateBottomNavigationBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void enableForm() {
    setState(() {
      isFormEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          QRDisplayPage(email: widget.email, timeStamp: widget.timeStamp),
          GeotrackPage(
            title: widget.title,
            description: widget.description,
          ),
          ReceiveNotifications(
            title: widget.title,
            description: widget.description,
          ),
          GiveFeedback(
            title: widget.title,
            description: widget.description,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey[300],
        onTap: _navigateBottomNavigationBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_sharp),
            label: "Qr For Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station_outlined),
            label: "Tracking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
