import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using standard default background instead of custom theme colors
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple raw icon
            const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.blue, 
            ),
            const SizedBox(height: 20),
            
            // Basic App Name Text
            const Text(
              'Shiftease Pune',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Added space before the button
            const SizedBox(height: 60),
            
            // Standard ElevatedButton with no custom styling, shadows, or icons
            ElevatedButton(
              onPressed: () {
                // The original navigation logic is perfectly preserved
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