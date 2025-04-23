import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Global RouteObserver to detect navigation events
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// Declare global constants for the API URLs
const String kResultsApiUrl =
    'https://2zj2lq4rhk.execute-api.us-east-2.amazonaws.com/results/presentation_audio.json';
const String kArgumentApiUrl =
    'https://2zj2lq4rhk.execute-api.us-east-2.amazonaws.com/results/argument_audio.json';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late Future<ApiResponse> _mainFuture;
  late Future<ApiResponse> _argumentFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _mainFuture = fetchSummary(kResultsApiUrl);
    _argumentFuture = fetchSummary(kArgumentApiUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reload both summaries when navigated back
    setState(() {
      _loadData();
    });
  }

  Future<ApiResponse> fetchSummary(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load summary from $url');
    }
  }

  Widget _buildSummarySection(String title, Future<ApiResponse> future) {
    return FutureBuilder<ApiResponse>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),
              Text('File: ${data.file}'),
              SizedBox(height: 8),
              ...data.summary.map((item) => Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(item.speaker.split('_').last),
                      ),
                      title: Text('Speaker: ${item.speaker}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emotion: ${item.emotion}'),
                          Text(
                              'Expressiveness: ${item.expressiveness.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ))
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Summary')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSummarySection('Default Summary', _mainFuture),
          SizedBox(height: 24),
          _buildSummarySection('Argument Audio Summary', _argumentFuture),
        ],
      ),
    );
  }
}

class ApiResponse {
  final String file;
  final List<SummaryEntry> summary;

  ApiResponse({required this.file, required this.summary});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['summary'] as List;
    List<SummaryEntry> summaryList =
        list.map((item) => SummaryEntry.fromJson(item)).toList();
    return ApiResponse(
      file: json['file'],
      summary: summaryList,
    );
  }
}

class SummaryEntry {
  final String speaker;
  final String emotion;
  final double expressiveness;

  SummaryEntry({
    required this.speaker,
    required this.emotion,
    required this.expressiveness,
  });

  factory SummaryEntry.fromJson(Map<String, dynamic> json) {
    return SummaryEntry(
      speaker: json['speaker'],
      emotion: json['emotion'],
      expressiveness: (json['expressiveness'] as num).toDouble(),
    );
  }
}

// In your MaterialApp (e.g., in main.dart), ensure:
// MaterialApp(
//   navigatorObservers: [routeObserver],
//   routes: { HomeScreen.routeName: (ctx) => HomeScreen() },
// );
