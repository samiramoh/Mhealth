import 'package:flutter/material.dart';
import 'package:mhealth/input_box.dart' as boxes;
import 'package:mhealth/login_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    // ignore: unused_local_variable
    final user = await _auth.currentUser;
    loggedInUser = user;
    debugPrint(loggedInUser?.email);
  }

  bool _isSmoker = false;
  String _gender = 'Male';
  String _cholesterol = 'Normal';
  String _glucose = 'Normal';
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

  void _onSave() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty) {
      _showAlertDialog('Error', 'Please fill in all fields.');
      return;
    }

    print(
        'Information saved with: Gender: $_gender, Smoker: $_isSmoker, Cholesterol: $_cholesterol, Glucose: $_glucose');
    // Here, you'd typically send the information to a server or save it locally

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginPage()));
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
        elevation: 0,
        backgroundColor: Colors.white,
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

            // ... Repeat similar code for last name, height, weight ...
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
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 15),
            const Text('Height'),
            const SizedBox(height: 15),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 178',
              ),
            ),
            const SizedBox(height: 15),
            const Text('Weight'),
            const SizedBox(height: 15),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 60',
              ),
            ),
            // ... Repeat for gender, smoker, cholesterol, glucose ...
            const SizedBox(height: 16),
            const boxes.InputBoxTitle(text: 'Gender'),
            buildGenderSelector(),
            const boxes.InputBoxTitle(text: 'Do you Smoke?'),
            buildSmokingSelector(),
            const boxes.InputBoxTitle(text: 'Cholesterol'),
            buildCholesterolSelector(),
            const boxes.InputBoxTitle(text: 'Glucose'),
            buildGlucoseSelector(),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 248, 250, 248),
                foregroundColor: Colors.grey,
              ),
              onPressed: _onSave,
              child: const Text('Save'),
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
    return SwitchListTile(
      title: const Text('Do you Smoke???'),
      value: _isSmoker,
      activeColor: Colors.green,
      onChanged: (bool value) {
        setState(() {
          _isSmoker = value;
        });
      },
    );
  }

  Widget buildCholesterolSelector() {
    return Column(
      children: <String>['Normal', 'Above Normal', 'Well above Normal']
          .map((String value) => RadioListTile<String>(
                title: Text(value),
                value: value,
                activeColor: Colors.green,
                groupValue: _cholesterol,
                onChanged: (String? selected) {
                  setState(() {
                    _cholesterol = selected ?? _cholesterol;
                  });
                },
              ))
          .toList(),
    );
  }

  Widget buildGlucoseSelector() {
    return Column(
      children: <String>['Normal', 'Above Normal', 'Well above Normal']
          .map((String value) => RadioListTile<String>(
                title: Text(value),
                value: value,
                activeColor: Colors.green,
                groupValue: _glucose,
                onChanged: (String? selected) {
                  setState(() {
                    _glucose = selected ?? _glucose;
                  });
                },
              ))
          .toList(),
    );
  }
}
