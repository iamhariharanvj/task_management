import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:manage_io/screens/home_screen.dart';
import 'package:manage_io/screens/login_screen.dart';
import 'package:manage_io/screens/members_screen.dart';
import 'package:manage_io/screens/onboarding_screen.dart';
import 'package:manage_io/screens/tasks_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Manage.io",
      home: OnBoardingScreen(),
    );
  }
}
