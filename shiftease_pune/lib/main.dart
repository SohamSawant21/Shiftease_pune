import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/request_provider.dart';
import 'utils/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/requester/my_requests_screen.dart';
import 'screens/requester/create_request_screen.dart';
import 'screens/requester/request_status_screen.dart';
import 'screens/worker/worker_dashboard.dart';
import 'screens/worker/job_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: const ShifteaseApp(),
    ),
  );
}

class ShifteaseApp extends StatelessWidget {
  const ShifteaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiftease Pune',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/my_requests': (context) => MyRequestsScreen(),
        '/create_request': (context) => const CreateRequestScreen(),
        '/request_status': (context) => const RequestStatusScreen(),
        '/worker_dashboard': (context) => const WorkerDashboard(),
        '/job_details': (context) => const JobDetailsScreen(),
      },
    );
  }
}