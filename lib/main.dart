import 'package:flutter/material.dart';

// นำเข้าไฟล์ Welcome Screen เพื่อใช้เป็นหน้าแรกสุด
import 'good_result_screen.dart';

void main() {
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
      home: const GoodResultScreen(),
    );
  }
}
