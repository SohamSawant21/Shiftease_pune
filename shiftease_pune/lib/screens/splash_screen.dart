import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.blue, 
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Shiftease Pune',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 60),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/role_selection');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}