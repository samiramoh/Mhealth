import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HealthDataPage extends StatefulWidget {
  const HealthDataPage({Key? key}) : super(key: key);

  @override
  _HealthDataPageState createState() => _HealthDataPageState();
}

class _HealthDataPageState extends State<HealthDataPage> {
  static const platform = MethodChannel('com.example.mhealth/health_connect');

  Future<List<dynamic>> readWeightInputs(DateTime start, DateTime end) async {
    final List<dynamic> weights = await platform.invokeMethod('readWeightInputs', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return weights;
  }

  Future<List<dynamic>> readExerciseSessions(DateTime start, DateTime end) async {
    final List<dynamic> sessions = await platform.invokeMethod('readExerciseSessions', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return sessions;
  }

  // Example method to trigger data fetch and handle results
  void fetchData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 1); // 1 day ago
    final end = now;

    final weights = await readWeightInputs(start, end);
    final sessions = await readExerciseSessions(start, end);

    // Process and display the fetched data as needed
    print('Weights: $weights');
    print('Sessions: $sessions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Data')),
      body: Center(
        child: ElevatedButton(
          onPressed: fetchData,
          child: const Text('Fetch Health Data'),
        ),
      ),
    );
  }
}
