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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists && userDoc.data()!.containsKey('currentMode')) {
          final mode = userDoc.data()!['currentMode'];
          
          if (mode == 'requester') {
            Navigator.pushReplacementNamed(context, '/my_requests');
          } else if (mode == 'worker') {
            Navigator.pushReplacementNamed(context, '/worker_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/role_selection');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/role_selection');
        }
      } catch (e) {
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
            CircularProgressIndicator(), 
          ],
        ),
      ),
    );
  }
}