import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditUserInfoPage extends StatefulWidget {
  const EditUserInfoPage({super.key});

  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? loggedInUser;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  final bool _isSmoker = false;
  String _smokingStatus = 'Never Smoked';
  String _gender = 'Male';
  String _cholesterol = 'Normal';
  String _glucose = 'Normal';
  bool _drinksAlcohol = false;
  bool _heartdisease = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserAndData();
  }

  void getCurrentUserAndData() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      fetchAndSetUserData();
    }
  }

  Future<void> fetchAndSetUserData() async {
    if (loggedInUser == null) return;

    try {
      var documentSnapshot =
          await _firestore.collection('user data').doc(loggedInUser!.uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null) {
          _firstNameController.text = data['Fname'] ?? '';
          _lastNameController.text = data['Lname'] ?? '';
          _heightController.text = data['Height'].toString();
          _weightController.text = data['Weight'].toString();
          if (data.containsKey('dateofbirth')) {
            DateTime dob = (data['dateofbirth'] as Timestamp).toDate();
            _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(dob);
          }
          _gender = data['gender'] == true ? 'Male' : 'Female';
          _smokingStatus = data['smoking_status'] ?? 'Never Smoked';
          _cholesterol = data['cholesterol'] ?? 'Normal';
          _glucose = data['Glucose'] ?? 'Normal';
          _drinksAlcohol = data['drinks_alcohol'] ?? false;
          _heartdisease = data['Heart_disease'] ?? false;
          setState(() {});
        }
      } else {
        debugPrint('No existing user data found.');
      }
    } catch (e) {
      debugPrint('Error fetching user data: ${e.toString()}');
    }
  }

  void saveUserData() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty) {
      _showAlertDialog('Error', 'All fields are required.');
      return;
    }

    final num height = num.tryParse(_heightController.text) ?? 0;
    final num weight = num.tryParse(_weightController.text) ?? 0;
    final DateTime dob =
        DateFormat('dd/MM/yyyy').parse(_dateOfBirthController.text);
    final Timestamp dobTimestamp = Timestamp.fromDate(dob);

    final userData = {
      'Fname': _firstNameController.text,
      'Lname': _lastNameController.text,
      'Height': height,
      'Weight': weight,
      'dateofbirth': dobTimestamp,
      'gender': _gender == 'Male',
      'smoking_status': _smokingStatus,
      'cholesterol': _cholesterol,
      'Glucose': _glucose,
      'drinks_alcohol': _drinksAlcohol,
      'Heart_disease': _heartdisease
    };

    try {
      await _firestore
          .collection('user data')
          .doc(loggedInUser!.uid)
          .set(userData, SetOptions(merge: true));
      Navigator.pop(context);
    } catch (e) {
      _showAlertDialog('Error', 'Failed to save user information: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, true); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveUserData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 20),
            const Text('Date of Birth:'),
            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Select Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _selectDate(context);
              },
            ),
            const SizedBox(height: 20),
            const Text('Height (cm):'),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Enter Height'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Weight (kg):'),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Enter Weight'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Gender:'),
            buildGenderSelector(),
            const SizedBox(height: 20),
            const Text('Smoking Status:'),
            buildSmokingSelector(),
            const SizedBox(height: 20),
            const Text('Cholesterol Level:'),
            buildCholesterolSelector(),
            const SizedBox(height: 20),
            const Text('Glucose Level:'),
            buildGlucoseSelector(),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Do you drink alcohol?'),
              value: _drinksAlcohol,
              onChanged: (bool value) {
                setState(() {
                  _drinksAlcohol = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Do you suffer from any heart disease?'),
              value: _heartdisease,
              activeColor: Colors.green,
              onChanged: (bool value) {
                setState(() {
                  _heartdisease = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUserData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirthController.text.isEmpty
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy').parse(_dateOfBirthController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Widget buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Male'),
            leading: Radio<String>(
              value: 'Male',
              groupValue: _gender,
              onChanged: (String? value) {
                setState(() {
                  _gender = value!;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Female'),
            leading: Radio<String>(
              value: 'Female',
              groupValue: _gender,
              onChanged: (String? value) {
                setState(() {
                  _gender = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSmokingSelector() {
    List<String> smokingOptions = ['Never Smoked', 'Formerly Smoked', 'Smokes'];
    return Column(
      children: smokingOptions.map((status) {
        return RadioListTile<String>(
          title: Text(status),
          value: status,
          groupValue: _smokingStatus,
          onChanged: (String? value) {
            setState(() {
              _smokingStatus = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildCholesterolSelector() {
    List<String> cholesterolLevels = [
      'Normal',
      'Above Normal',
      'Well Above Normal'
    ];
    return Column(
      children: cholesterolLevels.map((level) {
        return RadioListTile<String>(
          title: Text(level),
          value: level,
          groupValue: _cholesterol,
          onChanged: (String? value) {
            setState(() {
              _cholesterol = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildGlucoseSelector() {
    List<String> glucoseLevels = [
      'Below Normal',
      'Normal',
      'Above Normal',
      'Well Above Normal'
    ];
    return Column(
      children: glucoseLevels.map((level) {
        return RadioListTile<String>(
          title: Text(level),
          value: level,
          groupValue: _glucose,
          onChanged: (String? value) {
            setState(() {
              _glucose = value!;
            });
          },
        );
      }).toList(),
    );
  }
}
