import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Add a short delay so the user can actually see your logo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 1. Check if the user is currently logged in locally
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user session found. Go to Login.
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // 2. User is logged in! Let's check what dashboard they should see.
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists && userDoc.data()!.containsKey('currentMode')) {
          final mode = userDoc.data()!['currentMode'];
          
          // 3. Route them to their last active mode
          if (mode == 'requester') {
            Navigator.pushReplacementNamed(context, '/my_requests');
          } else if (mode == 'worker') {
            Navigator.pushReplacementNamed(context, '/worker_dashboard');
          } else {
            // Fallback if the mode is something unexpected
            Navigator.pushReplacementNamed(context, '/role_selection');
          }
        } else {
          // User exists but hasn't picked a role yet (e.g., they closed the app right after signing up)
          Navigator.pushReplacementNamed(context, '/role_selection');
        }
      } catch (e) {
        // Failsafe: If the database check fails (e.g., no internet), default to role selection
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role_selection');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 24),
            // Added a loading indicator so the user knows the app is "thinking"
            CircularProgressIndicator(), 
          ],
        ),
      ),
    );
  }
}