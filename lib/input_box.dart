import 'package:flutter/material.dart';

class InputBoxTitle extends StatelessWidget {
  final String text;

  const InputBoxTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InputBox extends StatelessWidget {
  final String label;
  final double width;
  final double height;

  const InputBox({
    super.key,
    required this.label,
    this.width = double.infinity, // or some default width if you prefer
    this.height = 48.0, // default height
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const TextField(
          // your TextField configuration
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
