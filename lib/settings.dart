import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mhealth/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPasswordChange =
      false; // Flag to control visibility of change password fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          if (_showPasswordChange)
            Column(
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
                ElevatedButton(
                  onPressed: changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ),
          if (!_showPasswordChange) // Show this button only if password fields are not visible
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showPasswordChange = true;
                });
              },
              child: const Text('Change Password'),
            ),
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void changePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _passwordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password fields cannot be empty')),
      );
      return;
    }

    // Verify the old password
    try {
      User? user = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPassword,
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);

      // Proceed to update to new password
      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      setState(() {
        _showPasswordChange =
            false; // Reset the flag to hide password change fields
        _oldPasswordController.clear();
        _passwordController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    }
  }

  void logout() {
    _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ); // Adjust this to your app's login route
  }
}
