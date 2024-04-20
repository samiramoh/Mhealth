import 'package:flutter/material.dart';
import 'package:mhealth/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mhealth/inputdata.dart';
import 'package:mhealth/home_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String errorMessage = ''; // Variable to hold the error message

  void signInWithEmailAndPassword() async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email and password.";
      });
      return;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Update the error message and refresh the UI
        errorMessage = e.message ?? 'An error occurred during sign in.';
      });
    } catch (e) {
      setState(() {
        // Update the error message for any other exceptions
        errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: MediaQuery.of(context).size.height * 0.2,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg', // Replace with your actual logo path
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: 24), // Space between image and text
              // ... rest of your widget tree ...
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              InputBoxWithLabel(
                label: 'Email',
                onChanged: (value) {
                  email = value;
                },
                isObscure: false,
              ),
              const SizedBox(height: 16),
              InputBoxWithLabel(
                label: 'Password',
                onChanged: (value) {
                  password = value;
                },
                isObscure: true,
              ),
              const SizedBox(height: 16),
              // ... Rest of the UI components, including buttons ...
              ElevatedButton(
                onPressed:
                    signInWithEmailAndPassword, // Updated to method reference
                // Button styling
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Don’t have an account? Sign up',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Health()),
                  );
              },
              child: const Text("Input"))
            ],
          ),
        ),
      ),
    );
  }
}

class InputBoxWithLabel extends StatelessWidget {
  final String label;
  final bool isObscure;
  final ValueChanged<String>? onChanged;

  const InputBoxWithLabel({
    required this.label,
    this.isObscure = false,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isObscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      ),
    );
  }
}