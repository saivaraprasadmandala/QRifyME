import 'package:flutter/material.dart';
import 'package:app/admin/selected_event.dart';
import 'package:app/admin/notification.dart';
import 'ask_feedback.dart';

class Navigation extends StatefulWidget {
  final String title;
  final String description;

  const Navigation({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  void _navigateBottomNavigationBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = <Widget>[
      SelectedEvent(
        title: widget.title,
        description: widget.description,
      ),
      AskFeedback(
        title: widget.title,
        description: widget.description,
      ),
      Notifications(
        title: widget.title,
        description: widget.description,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomNavigationBar,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[300],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            label: "Selected Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: "Send Updates",
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
