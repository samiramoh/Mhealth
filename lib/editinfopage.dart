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

  bool _isSmoker = false;
  String _gender = 'Male';
  String _cholesterol = 'Normal';
  String _glucose = 'Normal';

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
          // Initialize form fields with user data
          _firstNameController.text = data['Fname'] ?? '';
          _lastNameController.text = data['Lname'] ?? '';
          _heightController.text = data['Height'].toString();
          _weightController.text = data['Weight'].toString();
          if (data['dateofbirth'] != null) {
            DateTime dob = (data['dateofbirth'] as Timestamp).toDate();
            _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(dob);
          }
          _gender = data['gender'] == true ? 'Male' : 'Female';
          _isSmoker = data['smoker'] ?? false;
          _cholesterol = data['cholesterol'] ?? 'Normal';
          _glucose = data['Glucose'] ?? 'Normal';

          setState(() {}); // Update UI
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

    // Convert height and weight to numbers
    final num height = num.tryParse(_heightController.text) ?? 0;
    final num weight = num.tryParse(_weightController.text) ?? 0;

    // Convert date of birth to Timestamp
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
      'smoker': _isSmoker,
      'cholesterol': _cholesterol,
      'Glucose': _glucose,
    };

    try {
      await _firestore
          .collection('user data')
          .doc(loggedInUser!.uid)
          .set(userData, SetOptions(merge: true));
      Navigator.pop(context); // Optionally pop back to previous screen
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
                Navigator.of(context).pop(); // Close the dialog
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
            // First name field
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            // Last name field
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            // Date of Birth field
            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _selectDate(context);
              },
            ),
            // Height field
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            // Weight field
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            // Gender selector
            ListTile(
              title: const Text('Male'),
              leading: Radio<String>(
                value: 'Male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Female'),
              leading: Radio<String>(
                value: 'Female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
            // Smoking switch
            SwitchListTile(
              title: const Text('Smoker'),
              value: _isSmoker,
              onChanged: (bool value) {
                setState(() {
                  _isSmoker = value;
                });
              },
            ),
            // Assuming this is correctly implemented.
            const SizedBox(height: 16),
            buildCholesterolSelector(), // Corrected function call
            const SizedBox(height: 16),
            buildGlucoseSelector(), // Corrected function call
            const SizedBox(height: 24),
            // Cholesterol level
            //... similar to gender for selection
            // Glucose level
            //... similar to gender for selection

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

  // Additional methods for the form elements (if needed)...
}
