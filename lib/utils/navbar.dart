import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/recordings_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  // Define the pages for the navigation bar
  static List<Widget> _pages = <Widget>[HomeScreen(), RecordingsScreen()];

  // This method is called when an item in the BottomNavigationBar is tapped
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Show the selected page
        children: _pages, // Pages to display in IndexedStack
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Recordings',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected item
        onTap: _onTapped, // Handle tap and update index
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NavBar(),
  ));
}
