import 'package:flutter/material.dart';
//import 'package:mhealth/userinfo_page.dart'; // Ensure this is the correct path to your signup page
import 'package:mhealth/signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Make the page scrollable
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: MediaQuery.of(context).size.height *
                0.2, // Adjust the padding dynamically
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                20, // Padding for keyboard
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg', // Make sure this asset exists in your project
                width: MediaQuery.of(context).size.width *
                    0.6, // Responsive to the screen width
              ),
              const SizedBox(height: 24), // Space between image and text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const InputBoxWithLabel(
                label: 'Email',
                isObscure: false,
              ),
              const SizedBox(height: 16),
              const InputBoxWithLabel(
                label: 'Password',
                isObscure: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center, // Center the text horizontally
                child: GestureDetector(
                  onTap: () {
                    // Implement your "Forgot Password" logic here
                    print('Forgot Password tapped');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tahoma',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Implement your login logic here
                  print('Sign in button pressed');
                },
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
  const InputBoxWithLabel({
    required this.label,
    this.isObscure = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isObscure,
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
