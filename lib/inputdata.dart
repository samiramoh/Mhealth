import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'dart:convert';

class Health extends StatefulWidget {
  const Health({super.key});

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  // List<HealthConnectDataType> types = [
  //   HealthConnectDataType.ActiveCaloriesBurned,
  //   HealthConnectDataType.BasalBodyTemperature,
  //   HealthConnectDataType.BasalMetabolicRate,
  //   HealthConnectDataType.BloodGlucose,
  //   HealthConnectDataType.BloodPressure,
  //   HealthConnectDataType.BodyFat,
  //   HealthConnectDataType.BodyTemperature,
  //   HealthConnectDataType.BoneMass,
  //   HealthConnectDataType.CervicalMucus,
  //   HealthConnectDataType.CyclingPedalingCadence,
  //   HealthConnectDataType.Distance,
  //   HealthConnectDataType.ElevationGained,
  //   HealthConnectDataType.ExerciseSession,
  //   HealthConnectDataType.FloorsClimbed,
  //   HealthConnectDataType.HeartRate,
  //   HealthConnectDataType.Height,
  //   HealthConnectDataType.Hydration,
  //   HealthConnectDataType.LeanBodyMass,
  //   HealthConnectDataType.MenstruationFlow,
  //   HealthConnectDataType.Nutrition,
  //   HealthConnectDataType.OvulationTest,
  //   HealthConnectDataType.OxygenSaturation,
  //   HealthConnectDataType.Power,
  //   HealthConnectDataType.RespiratoryRate,
  //   HealthConnectDataType.RestingHeartRate,
  //   HealthConnectDataType.SexualActivity,
  //   HealthConnectDataType.SleepSession,
  //   HealthConnectDataType.SleepStage,
  //   HealthConnectDataType.Speed,
  //   HealthConnectDataType.StepsCadence,
  //   HealthConnectDataType.Steps,
  //   HealthConnectDataType.TotalCaloriesBurned,
  //   HealthConnectDataType.Vo2Max,
  //   HealthConnectDataType.Weight,
  //   HealthConnectDataType.WheelchairPushes,
  // ];

  List<HealthConnectDataType> types = [
    HealthConnectDataType.Steps,
    //HealthConnectDataType.ExerciseSession,
    HealthConnectDataType.HeartRate,
    HealthConnectDataType.SleepSession,
    HealthConnectDataType.BloodPressure,
    HealthConnectDataType.SleepStage
    // HealthConnectDataType.OxygenSaturation,
    // HealthConnectDataType.RespiratoryRate,
  ];

  bool readOnly = true;
  String resultText = '';

  String token = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Connect'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // IsApiSupported
            ElevatedButton(
              onPressed: () async {
                var result = await HealthConnectFactory.isApiSupported();
                resultText = 'isApiSupported: $result';
                _updateResultText(resultText);
              },
              child: const Text('isApiSupported'),
            ),
            // Install Health Connect
            ElevatedButton(
              onPressed: () async {
                try {
                  await HealthConnectFactory.installHealthConnect();
                  resultText = 'Install activity started';
                } catch (e) {
                  resultText = e.toString();
                }
                _updateResultText(resultText);
              },
              child: const Text('Install Health Connect'),
            ),
            // Open Health Connect Settings
            ElevatedButton(
              onPressed: () async {
                try {
                  await HealthConnectFactory.openHealthConnectSettings();
                  resultText = 'Settings activity started';
                } catch (e) {
                  resultText = e.toString();
                }
                _updateResultText(resultText);
              },
              child: const Text('Open Health Connect Settings'),
            ),
            // Has Permissions
            ElevatedButton(
              onPressed: () async {
                var result = await HealthConnectFactory.hasPermissions(
                  types,
                  readOnly: readOnly,
                );
                resultText = 'hasPermissions: $result';
                _updateResultText(resultText);
              },
              child: const Text('Has Permissions'),
            ),
            // Request Permissions
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await HealthConnectFactory.requestPermissions(
                    types,
                    readOnly: readOnly,
                  );
                  resultText = 'requestPermissions: $result';
                } catch (e) {
                  resultText = e.toString();
                }
                _updateResultText(resultText);
              },
              child: const Text('Request Permissions'),
            ),
            Text(resultText),
          ],
        ),
      ),
    );
  }

  void _updateResultText(String text) {
    setState(() {
      resultText = text;
    });
  }

  Future<void> getHeartRateData() async {
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
          : 0;

      // Update the UI
      _updateResultText(
          'Average Heart Rate: ${averageHeartRate.toStringAsFixed(2)} bpm');
    } catch (e) {
      _updateResultText('Error fetching heart rate data: $e');
    }
  }

  ////////////////////////////////////////////////////////
  ///
  Future<void> getsteps() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 4));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.Steps,
        startTime: startTime,
        endTime: endTime,
      );

      // Assuming the structure of the map matches the JSON data provided
      List<dynamic> heartRateRecords = recordData['records'];

      // Extracting the heart rates and calculating the average
      List<int> sleepscores = [];
      for (var record in heartRateRecords) {
        sleepscores.add(record['count']);
      }

      // Calculate average
      double averageHeartRate = sleepscores.isNotEmpty
          ? sleepscores.reduce((a, b) => a + b) / sleepscores.length
          : 0;

      // Update the UI
      _updateResultText(
          'steps daily: ${averageHeartRate.toStringAsFixed(2)} bpm');
    } catch (e) {
      _updateResultText('Error fetching heart rate data: $e');
    }
  }

  ///////////////////////////////////////////////////
  Future<void> getSystolic() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.BloodPressure,
        startTime: startTime,
        endTime: endTime,
      );

      // Assuming the structure of the map matches the JSON data provided
      List<dynamic> systolicRecords = recordData['records'];

      // Extracting the systolic values and calculating the average
      List<double> systolicValues = [];
      for (var record in systolicRecords) {
        if (record['systolic'] is Map) {
          systolicValues.add(record['systolic']['millimetersOfMercury']);
        }
      }

      // Calculate average
      double averageSystolic = systolicValues.isNotEmpty
          ? systolicValues.reduce((a, b) => a + b) / systolicValues.length
          : 0.0; // If there are no records, the average should be 0.

      // Update the UI
      _updateResultText(
          'Average Systolic Blood Pressure: ${averageSystolic.toStringAsFixed(2)} mmHg');
    } catch (e) {
      _updateResultText('Error fetching systolic blood pressure data: $e');
    }
  }

  ///////////////////////////////////
  Future<void> getdiastolic() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
    DateTime endTime = DateTime.now();

    try {
      Map<String, dynamic> recordData = await HealthConnectFactory.getRecord(
        type: HealthConnectDataType.BloodPressure,
        startTime: startTime,
        endTime: endTime,
      );

      // Assuming the structure of the map matches the JSON data provided
      List<dynamic> systolicRecords = recordData['records'];

      // Extracting the systolic values and calculating the average
      List<double> systolicValues = [];
      for (var record in systolicRecords) {
        if (record['diastolic'] is Map) {
          systolicValues.add(record['diastolic']['millimetersOfMercury']);
        }
      }

      // Calculate average
      double averagediastolic = systolicValues.isNotEmpty
          ? systolicValues.reduce((a, b) => a + b) / systolicValues.length
          : 0.0; // If there are no records, the average should be 0.

      // Update the UI
      _updateResultText(
          'Average diastolic Blood Pressure: ${averagediastolic.toStringAsFixed(2)} mmHg');
    } catch (e) {
      _updateResultText('Error fetching diastolic blood pressure data: $e');
    }
  }

  ///////////////////////////////////////////
  Future<String> getSleepSession() async {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 2));
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
            _updateResultText(
                'Average diastolic Blood Pressure: $formattedSleepDuration mmHg');
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
}
