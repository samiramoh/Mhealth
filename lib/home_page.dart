import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HealthDashboard(),
    );
  }
}

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  final firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  static const platform =
      MethodChannel('com.yourcompany/health_connect_channel');

  String username = "";
  double height = 0;
  double weight = 0;
  double bmi = 0;
  int heartRate = 0;
  // Add other health data variables here

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getHealthData(); // Fetch health data when the screen initializes
  }

  Future<void> getHealthData() async {
    try {
      final int resultHeartRate = await platform.invokeMethod('getHeartRate');
      setState(() {
        heartRate = resultHeartRate;
      });
    } on PlatformException catch (e) {
      setState(() {
        heartRate = 0; // Default or error value
      });
      print("Failed to get heart rate: '${e.message}'.");
    }
  }

  fetchUserData() {
    User? user = auth.currentUser;
    firestoreInstance.collection('users').doc(user?.uid).get().then((value) {
      setState(() {
        username = value.data()?['name'];
        height = value.data()?['height'];
        weight = value.data()?['weight'];
        bmi = calculateBMI(height, weight);
      });
    }).catchError((error) {
      print("Failed to fetch user data: $error");
    });
  }

  double calculateBMI(double height, double weight) {
    // Assuming height in meters and weight in kilograms
    return weight / (height * height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Good Afternoon, $username"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Heart Rate: $heartRate BPM'), // Display the fetched heart rate
            // Display other health data
            Text('BMI: ${bmi.toStringAsFixed(2)} (${getBMICategory(bmi)})'),
            // Display emergency contact
          ],
        ),
      ),
    );
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }
}
