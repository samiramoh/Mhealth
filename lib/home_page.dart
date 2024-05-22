import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:mhealth/editinfopage.dart';
import 'package:mhealth/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserData> userDataFuture;
  int? userStressLevel;
  int heartrate = 0;
  double systolics = 0;
  double diastolics = 0;
  int activity = 0;
  int steps = 0;
  String sleep = 'No data';
  String processedData = "No processed data yet";
  String vars = "All Good!";
  late int age;
  final String _message = '';
  late bool gender;

  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showStressLevelDialog(); // Call this after the initial frame is rendered
    });
    fetchAllHealthData();
  }

  Future<void> showStressLevelDialog() async {
    int? selectedStressLevel = await showDialog<int>(
      context: context,
      barrierDismissible: false, // User must tap a button.
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text(
              'In a scale from 1 to 10 how stressed are you? (10 is the significant level of depression)'),
          children: List<Widget>.generate(
              10,
              (index) => SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(dialogContext,
                          index + 1); // Pass the index + 1 as the result
                    },
                    child: Text('Stress level ${index + 1}'),
                  )),
        );
      },
    );

    if (selectedStressLevel != null) {
      setState(() {
        userStressLevel = selectedStressLevel;
        sendHealthData();
      });
    }
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
    var Glucose = data['Glucose'] as String;
    var smokingStatus = data['smoking_status'] as String;
    var drinksAlcohol = data['drinks_alcohol'] as bool;
    var heartDisease = data['Heart_disease'] as bool;
    var chol = data['cholesterol'] as String;
    Timestamp? dobTimestamp = data['dateofbirth'] as Timestamp?;
    var gender = data['gender'] as bool;
    if (name == null) {
      throw Exception('Name field is missing in user data.');
    }
    if (height == null) {
      throw Exception('Height field is missing in user data.');
    }
    if (weight == null) {
      throw Exception('Weight field is missing in user data.');
    }
    if (dobTimestamp == null) {
      throw Exception('Date of Birth field is missing in user data.');
    }

    DateTime dateOfBirth = dobTimestamp.toDate();
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - dateOfBirth.year;
    if (currentDate.month < dateOfBirth.month ||
        (currentDate.month == dateOfBirth.month &&
            currentDate.day < dateOfBirth.day)) {
      age--;
    }
    return UserData(
        name: name,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        Glucose: Glucose,
        smoking_status: smokingStatus,
        drinks_alcohol: drinksAlcohol,
        heart_disease: heartDisease,
        chol: chol);
  }

  Future<void> fetchAllHealthData() async {
    heartrate = await getHeartRateData();
    systolics = await getSystolic();
    diastolics = await getDiastolic();
    activity = await getTotalActivityMinutes();
    steps = await getSteps;
    sleep = await getSleepSession();
  }

  ////////////////////////////////////////////////////////
  Future<int> getHeartRateData() async {
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
      int lastHeartRate = heartRates.isNotEmpty ? heartRates.last : 0;
      // Calculate average
      return lastHeartRate;
    } catch (e) {
      // Log the error and return a default value
      print('Error fetching heart rate data: $e');
      return 0; // return a default value or consider rethrowing the exception
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
      systolics = systolic;
      diastolics = diastolic;
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

  Future<int> getTotalActivityMinutes() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();

    try {
      // Assuming this is how you fetch the records, modify as per your actual implementation
      Map<String, dynamic> activityData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.Steps,
        startTime: startTime,
        endTime: endTime,
      );

      List<dynamic> stepRecords = activityData['records'];

      int totalSeconds = 0;
      for (var record in stepRecords) {
        // Ensure to check the structure of your record to access the start and end times correctly
        int recordStartEpoch = record['startTime']['epochSecond'];
        int recordEndEpoch = record['endTime']['epochSecond'];
        totalSeconds += (recordEndEpoch - recordStartEpoch);
      }

      // Convert the total seconds to total minutes
      int totalMinutes = totalSeconds ~/ 60;
      return totalMinutes;
    } catch (e) {
      print('Error fetching activity data: $e');
      return 0; // Return 0 or handle the error as needed
    }
  }

  ///////////////////////////////////////////////////////
  Future<void> sendHealthData() async {
    var url = Uri.parse(
        'https://8f0f-79-134-131-24.ngrok-free.app/submit_health_data/');
    UserData userData = await userDataFuture;

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_stress_level': userStressLevel ?? 0,
        'weight': userData.weight,
        'height': userData.height,
        'age': userData.age,
        'heart_rate': heartrate,
        'systolic': systolics,
        'diastolic': diastolics,
        'physical_activity_minutes': activity,
        'steps': steps,
        'sleep_duration': sleep,
        'gender': userData.gender,
        'alcohol': userData.drinks_alcohol,
        'Glucose': userData.Glucose,
        'smoking_status': userData.smoking_status,
        'Heart_disease': userData.heart_disease,
        'chol': userData.chol
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        processedData = response.body;
        // Updating the state with processed data
      });
    } else {
      print('Failed to send data: ${response.statusCode}');
      processedData = "No processed data";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sentiment_very_dissatisfied,
                color: Colors.orange),
            onPressed: showStressLevelDialog, // Trigger stress level dialog
          ),
        ],
      ),
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
                const SizedBox(height: 20),
                Text('Hello, ${user.name}!',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                buildHealthCard('Heart Rate', '$heartrate BPM',
                    'assets/images/heartrate.png'),
                buildHealthCard('Blood Pressure', '$systolics/$diastolics',
                    'assets/images/bloodpress.png'),
                buildHealthCard(
                    'Steps', '$steps SPD', 'assets/images/steps.png'),
                buildHealthCard(
                    'Sleep Duration', sleep, 'assets/images/sleep.png'),
                buildBmiCard(user), // BMI card
                buildHospitalMessageCard(),
                // Hospital message card
                if (processedData == '"All Good!"') ...[
                  buildGreenTechCard()
                ] else ...[
                  buildAlertCard(),
                  Text('ALERT ! $processedData',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16)),
                ] // Alert card
              ],
            ));
          } else {
            return Container(); // Default empty container when no data is fetched
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Assuming the home page is index 0
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit Info'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget buildBmiCard(UserData user) {
    return Card(
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
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            trailing: Text(
              user.calculateBMI().toStringAsFixed(2),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHospitalMessageCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: const Text(
          'If you feel the need to go to the hospital, don\'t hesitate to call emergency services.',
        ),
        leading: const Icon(Icons.warning, color: Colors.orange),
        onTap: () {
          // _makePhoneCall('911');
        },
      ),
    );
  }

  Widget buildAlertCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.redAccent,
      child: ListTile(
        title: const Text('ALERT!', style: TextStyle(color: Colors.white)),
        leading: const Icon(Icons.add_alert, color: Colors.white),
        onTap: () {},
      ),
    );
  }

  Widget buildGreenTechCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.green, // Change color to green
      child: ListTile(
        title: const Text('You are all well!',
            style: TextStyle(color: Colors.white)),
        leading: const Icon(Icons.check_circle,
            color: Colors.white), // Change icon to green tick
        onTap: () {},
      ),
    );
  }

  Widget buildHealthCard(String title, String value, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Image.asset(imagePath, width: 24, height: 24),
        title: Text(title),
        trailing: Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class UserData {
  final String name;
  final double height;
  final double weight;
  final int age; // Changed to DateTime for easier handling in Flutter
  final bool gender;
  // ignore: non_constant_identifier_names
  final String Glucose;
  // ignore: non_constant_identifier_names
  final String smoking_status;
  // ignore: non_constant_identifier_names
  final bool drinks_alcohol;
  final bool heart_disease;
  final String chol;

  UserData(
      {required this.name,
      required this.height,
      required this.weight,
      required this.age,
      required this.gender,
      // ignore: non_constant_identifier_names
      required this.Glucose,
      // ignore: non_constant_identifier_names
      required this.smoking_status,
      // ignore: non_constant_identifier_names
      required this.drinks_alcohol,
      required this.heart_disease,
      required this.chol});

  double calculateBMI() {
    if (height <= 0 || weight <= 0) {
      return 0; // Handle invalid data
    }
    return weight / ((height * height) / 10000);
  }

  String getBmiCategory() {
    double bmi = calculateBMI();
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}
