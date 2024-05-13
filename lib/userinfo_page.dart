import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mhealth/login_page.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      debugPrint(loggedInUser?.email);
    }
  }

  String _smokingStatus = 'Never Smoked';
  String _gender = 'Male';
  String _cholesterol = 'Normal';
  String _glucose = 'Normal';
  bool _drinksAlcohol = false;
  bool _heartdisease = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _onSave() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty) {
      _showAlertDialog('Error', 'Please fill in all fields.');
      return;
    }

    final num height = num.tryParse(_heightController.text) ?? 0;
    final num weight = num.tryParse(_weightController.text) ?? 0;
    final bool genderBool = _gender == 'Male';
    final DateFormat format = DateFormat('dd/MM/yyyy');
    final DateTime dob = format.parse(_dateOfBirthController.text);
    final Timestamp dobTimestamp = Timestamp.fromDate(dob);

    final userData = {
      'Fname': _firstNameController.text,
      'Lname': _lastNameController.text,
      'Height': height,
      'Weight': weight,
      'dateofbirth': dobTimestamp,
      'gender': genderBool,
      'smoking_status': _smokingStatus,
      'cholesterol': _cholesterol,
      'Glucose': _glucose,
      'drinks_alcohol': _drinksAlcohol,
      'Heart_disease': _heartdisease
    };

    try {
      await _firestore
          .collection('user data')
          .doc(loggedInUser?.uid)
          .set(userData, SetOptions(merge: true));
      debugPrint(
          'User information saved to Firestore in the user data collection.');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoginPage()));
    } catch (e) {
      _showAlertDialog('Error', 'Failed to save user information.');
      debugPrint(e.toString());
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text('First Name'),
            const SizedBox(height: 15),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Noor',
              ),
            ),
            const SizedBox(height: 15),
            const Text('Last Name'),
            const SizedBox(height: 15),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Alawi',
              ),
            ),
            const SizedBox(height: 15),
            const Text('Date of Birth'),
            const SizedBox(height: 15),
            TextField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'DD/MM/YYYY',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 15),
            const Text('Height (cm)'),
            const SizedBox(height: 15),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 178',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            const Text('Weight (kg)'),
            const SizedBox(height: 15),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 70',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Gender'),
            buildGenderSelector(),
            const SizedBox(height: 16),
            const Text('Smoking Status'),
            buildSmokingSelector(),
            const SizedBox(height: 16),
            const Text('Cholesterol Level'),
            buildCholesterolSelector(),
            const SizedBox(height: 16),
            const Text('Glucose Level'),
            buildGlucoseSelector(),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Do you drink alcohol?'),
              value: _drinksAlcohol,
              activeColor: Colors.green,
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
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _onSave,
              child: const Text('Save Information'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenderSelector() {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            title: const Text('Male'),
            leading: Radio<String>(
              value: 'Male',
              groupValue: _gender,
              onChanged: (String? value) {
                setState(() {
                  _gender = value ?? _gender;
                });
              },
              activeColor: Colors.green,
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
                  _gender = value ?? _gender;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSmokingSelector() {
    return Column(
      children: <String>['never smoked', 'formerly smoked', 'smokes']
          .map((String value) => RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: _smokingStatus,
                onChanged: (String? selected) {
                  setState(() {
                    _smokingStatus = selected ?? _smokingStatus;
                  });
                },
                activeColor: Colors.green,
              ))
          .toList(),
    );
  }

  Widget buildCholesterolSelector() {
    return Column(
      children: <String>['Normal', 'Above Normal', 'Well Above Normal']
          .map((String value) => RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: _cholesterol,
                onChanged: (String? selected) {
                  setState(() {
                    _cholesterol = selected ?? _cholesterol;
                  });
                },
                activeColor: Colors.green,
              ))
          .toList(),
    );
  }

  Widget buildGlucoseSelector() {
    return Column(
      children: <String>[
        'Below Normal',
        'Normal',
        'Above Normal',
        'Well Above Normal'
      ]
          .map((String value) => RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: _glucose,
                onChanged: (String? selected) {
                  setState(() {
                    _glucose = selected ?? _glucose;
                  });
                },
                activeColor: Colors.green,
              ))
          .toList(),
    );
  }
}
