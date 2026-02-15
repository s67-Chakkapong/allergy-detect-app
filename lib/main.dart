import 'package:flutter/material.dart';
import 'register_screen.dart'; // อย่าลืม Import ไฟล์ที่เพิ่งสร้าง
import 'login_screen.dart'; // อย่าลืม Import ไฟล์ที่เพิ่งสร้าง

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // เรียกใช้หน้า Login เป็นหน้าแรก
    );
  }
}
