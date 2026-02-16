import 'package:flutter/material.dart';
import 'identify_allergy_screen.dart'; // อย่าลืม Import ไฟล์ที่เพิ่งสร้าง

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IdentifyAllergyScreen(), // เรียกใช้หน้า Register เป็นหน้าแรก
    );
  }
}
