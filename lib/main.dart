import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // 👈 ADD THIS LINE

// นำเข้าไฟล์ Welcome Screen เพื่อใช้เป็นหน้าแรกสุด
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Allergy Detect App',
      // กำหนดให้เปิดแอปมาเจอหน้า WelcomeScreen เป็นหน้าแรก
      home: WelcomeScreen(),
    ); // MaterialApp
  }
}
