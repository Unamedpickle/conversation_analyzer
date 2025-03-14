import 'package:flutter/material.dart';

class RecordingsScreen extends StatefulWidget {
  @override
  _RecordingsScreenState createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recordings Screen'),
      ),
      body: Center(
        child: Text('Recordings Screen'),
      ),
    );
  }
}
