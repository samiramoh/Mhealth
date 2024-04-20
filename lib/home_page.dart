import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:mhealth/editinfopage.dart';
import 'package:mhealth/settings.dart';
//import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserData> userDataFuture;
  final int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData();
  }

  Future<UserData> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in.');
    }

    var documentSnapshot = await FirebaseFirestore.instance
        .collection('user data')
        .doc(user.uid)
        .get();

    if (!documentSnapshot.exists) {
      throw Exception('User data not found.');
    }

    var data = documentSnapshot.data();
    if (data == null) {
      throw Exception('User data is null.');
    }

    var name = data['Fname'] as String?;
    var height = (data['Height'] as num?)?.toDouble();
    var weight = (data['Weight'] as num?)?.toDouble();

    if (name == null || height == null || weight == null) {
      throw Exception('Missing user data fields.');
    }

    return UserData(name: name, height: height, weight: weight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserData>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            UserData user = snapshot.data!;
            return SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text('Hello, ${user.name}!',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                FutureBuilder<double>(
                  future: getHeartRateData(),
                  builder: (context, heartRateSnapshot) {
                    return _buildHealthCard(
                      'Heart Rate',
                      heartRateSnapshot.hasData
                          ? '${heartRateSnapshot.data} BPM'
                          : 'Loading...',
                      'assets/images/heartrate.png',
                      Colors.red,
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: getBloodPressure(),
                  builder: (context, snapshot) {
                    return _buildHealthCard(
                      'Blood Pressure',
                      snapshot.hasData ? snapshot.data! : 'Loading...',
                      'assets/images/bloodpress.png',
                      Colors.redAccent,
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: getSteps,
                  builder: (context, stepsSnapshot) {
                    return _buildHealthCard(
                      'Steps',
                      stepsSnapshot.hasData
                          ? '${stepsSnapshot.data} SPD'
                          : 'Loading...',
                      'assets/images/steps.png',
                      Colors.black,
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: getSleepSession(),
                  builder: (context, sleepSnapshot) {
                    return _buildHealthCard(
                      'Sleep Duration',
                      sleepSnapshot.hasData
                          ? sleepSnapshot.data!
                          : 'Loading...',
                      'assets/images/sleep.png',
                      Colors.deepPurple,
                    );
                  },
                ),
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          'assets/images/bmi.png',
                          width: 70,
                          height: 70,
                        ),
                        title: const Text('BMI',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          user.getBmiCategory(),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        trailing: Text(
                          user.calculateBMI().toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hospital Message Card
                Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: const Text(
                      'If you feel the need to go to the hospital, don\'t hesitate to call emergency services.',
                    ),
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    onTap: () {
                      // _makePhoneCall('911');
                    },
                  ),
                ),

                // Alert Card
                Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  color: Colors.redAccent,
                  child: ListTile(
                    title: const Text('ALERT!',
                        style: TextStyle(color: Colors.white)),
                    leading: const Icon(Icons.add_alert, color: Colors.white),
                    onTap: () {
                      // Implement alert action
                    },
                  ),
                ),
              ],
            ));
          } else {
            return Container(); // Default empty container when no data is fetched
          }
        },
      ),
      ////////////////////////////

      ///////////////////////////
      bottomNavigationBar: BottomNavigationBar(
        // Define the index of the current selected item in BottomNavigationBar
        currentIndex: 0, // Assuming the home page is index 0
        // Update the state and navigate when an item is tapped
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditUserInfoPage()));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
    // ignore: dead_code
  }

  Widget _buildHealthCard(
      String title, String value, String imagePath, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Image.asset(imagePath, color: color, width: 24, height: 24),
        title: Text(title),
        trailing: Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<double> getHeartRateData() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 4));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.HeartRate,
        startTime: startTime,
        endTime: endTime,
      );

      // Assuming the structure of the map matches the JSON data provided
      List<dynamic> heartRateRecords = recordData['records'];

      // Extracting the heart rates and calculating the average
      List<int> heartRates = [];
      for (var record in heartRateRecords) {
        List<dynamic> samples = record['samples'];
        for (var sample in samples) {
          heartRates.add(sample['beatsPerMinute']);
        }
      }

      // Calculate average
      double averageHeartRate = heartRates.isNotEmpty
          ? heartRates.reduce((a, b) => a + b) / heartRates.length
          : 0.0;

      return averageHeartRate;
    } catch (e) {
      // Log the error and return a default value
      print('Error fetching heart rate data: $e');
      return 0.0; // return a default value or consider rethrowing the exception
    }
  }

  ////////////////////////////////////////////////////////
  ///
  Future<int> get getSteps async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();
    int totalSteps = 0;
    String? nextPageToken;

    do {
      Map<String, dynamic> response = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.Steps,
        startTime: startTime,
        endTime: endTime,
        pageToken: nextPageToken, // Pass the next page token if one exists
      );

      List<dynamic> stepRecords = response['records'];
      totalSteps += stepRecords.fold<int>(
          0, (sum, record) => sum + (record['count'] as int? ?? 0));

      nextPageToken = response['nextPageToken']
          as String?; // Assuming the API provides a nextPageToken
    } while (nextPageToken != null);

    return totalSteps;
  }

  ///////////////////////////////////////////////////getSystolic
  Future<double> getSystolic() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.BloodPressure,
        startTime: startTime,
        endTime: endTime,
      );

      List<dynamic> systolicRecords = recordData['records'];

      if (systolicRecords.isNotEmpty) {
        // Assuming the newest record is at the end of the list
        var latestRecord = systolicRecords.last;
        if (latestRecord['systolic'] is Map) {
          return latestRecord['systolic']['millimetersOfMercury'];
        }
      }

      print('No systolic data available.');
      return 0.0; // Return a default value if no data is available
    } catch (e) {
      print('Error fetching latest systolic blood pressure data: $e');
      return 0.0; // Return a default value in case of an error
    }
  }

  ///////////////////////////////////getDiastolic
  Future<double> getDiastolic() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.BloodPressure,
        startTime: startTime,
        endTime: endTime,
      );

      List<dynamic> diastolicRecords = recordData['records'];

      if (diastolicRecords.isNotEmpty) {
        // Assuming the newest record is at the end of the list
        var latestRecord = diastolicRecords.last;
        if (latestRecord['diastolic'] is Map) {
          return latestRecord['diastolic']['millimetersOfMercury'];
        }
      }

      print('No diastolic data available.');
      return 0.0; // Return a default value if no data is available
    } catch (e) {
      print('Error fetching latest diastolic blood pressure data: $e');
      return 0.0; // Return a default value in case of an error
    }
  }
  //////////////////////////////////

  Future<String> getBloodPressure() async {
    try {
      double systolic = await getSystolic();
      double diastolic = await getDiastolic();
      int v = systolic.toInt();
      int d = diastolic.toInt();
      return "$v/$d";
    } catch (e) {
      print('Error fetching blood pressure data: $e');
      return "Error";
    }
  }

  ///////////////////////////////////////////
  Future<String> getSleepSession() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();
    String formattedSleepDuration =
        'No data'; // default message in case there's no session

    try {
      Map<String, dynamic> jsonData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.SleepSession,
        startTime: startTime,
        endTime: endTime,
      );

      if (jsonData['records'] != null) {
        List<dynamic> sleepSessions = jsonData['records'];

        if (sleepSessions.isNotEmpty) {
          // Ensure there's at least one session
          for (var session in sleepSessions) {
            int startEpochSeconds = session['startTime']['epochSecond'];
            DateTime sessionStartTime = DateTime.fromMillisecondsSinceEpoch(
                    startEpochSeconds * 1000,
                    isUtc: true)
                .toLocal();

            int endEpochSeconds = session['endTime']['epochSecond'];
            DateTime sessionEndTime = DateTime.fromMillisecondsSinceEpoch(
                    endEpochSeconds * 1000,
                    isUtc: true)
                .toLocal();

            Duration sleepDuration =
                sessionEndTime.difference(sessionStartTime);
            formattedSleepDuration =
                '${sleepDuration.inHours}:${sleepDuration.inMinutes.remainder(60)}:${sleepDuration.inSeconds.remainder(60)}';
            break; // Assuming you only need the first session for now
          }
        } else {
          formattedSleepDuration =
              'No sleep sessions found'; // handle empty sleepSessions
        }
      } else {
        formattedSleepDuration =
            'Records key not present in data'; // handle null records
      }
    } catch (e) {
      print('Error fetching sleep session data: $e');
      return 'Error'; // You can decide to return an error string or throw an exception
    }

    return formattedSleepDuration; // Ensure a string is always returned
  }

  // Future<void> _makePhoneCall(String phoneNumber) async {
  //   final Uri launchUri = Uri(
  //     scheme: 'tel',
  //     path: phoneNumber,
  //   );
  //   if (await canLaunchUrl(launchUri)) {
  //     await launchUrl(launchUri);
  //   } else {
  //     throw 'Could not launch $launchUri';
  //   }
  // }
}

class UserData {
  String name;
  double height;
  double weight;

  UserData({required this.name, required this.height, required this.weight});

  double calculateBMI() {
    if (height <= 0 || weight <= 0) {
      return 0; // Handle invalid data
    }
    return weight / ((height * height) / 10000);
  }

  String getBmiCategory() {
    double bmi = calculateBMI();
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi < 25) return 'Normal weight';
    if (bmi >= 25 && bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
