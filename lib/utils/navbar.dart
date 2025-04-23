import 'package:conversation_analyzer/screens/recording_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/saved_recordings_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final GlobalKey<SavedRecordingsScreenState> _recordingsKey =
      GlobalKey<SavedRecordingsScreenState>();

  // Define the pages for the navigation bar
  List<Widget> _pages() => <Widget>[
        SavedRecordingsScreen(key: _recordingsKey),
        HomeScreen(),
        RecordingScreen(),
      ];

  // This method is called when an item in the BottomNavigationBar is tapped
  void _onTapped(int index) {
    setState(() {
      if (index == 1) {
        _recordingsKey.currentState?.refreshRecordings();
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Specify the currently selected page
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Recordings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NavBar(),
  ));
}
