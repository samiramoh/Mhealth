import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print('Button Pressed');
      },
      child: const Text('Check Health Connect'),
    );
  }
}
