import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;

  // Function to save the mode and navigate
  Future<void> _selectRole(String mode, String route) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the user's current mode in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'currentMode': mode,
        });

        // Navigate to the correct dashboard using pushNamed
        // This keeps the Role Selection screen in the stack, enabling the back button!
        if (mounted) {
          Navigator.pushReplacementNamed(context, route);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating role. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shiftease Pune',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Restored left alignment
                  children: [
                    // Basic Title restored to match original design
                    const Text(
                      'Select Your Role',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose how you want to use the app right now.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Requester Option (Simple Card UI)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _selectRole('requester', '/my_requests'),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 40, color: Colors.blue),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I Need Help Shifting', 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Post a request to find workers', 
                                      style: TextStyle(color: Colors.grey)
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Worker Option (Simple Card UI)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _selectRole('worker', '/worker_dashboard'),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Icon(Icons.work_outline, size: 40, color: Colors.blue),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I Want to Work', 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Find and accept shifting jobs', 
                                      style: TextStyle(color: Colors.grey)
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
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