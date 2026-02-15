import 'dart:async';
import 'package:flutter/material.dart';
import 'register_screen.dart'; 

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _timer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // เริ่มจับเวลา 5 วินาทีเมื่อหน้านี้ถูกสร้างขึ้น
    _timer = Timer(const Duration(seconds: 5), _goToNextScreen);
  }

  void _goToNextScreen() {
    // เช็คว่ากำลังเปลี่ยนหน้าอยู่หรือไม่ เพื่อป้องกันการเปลี่ยนหน้าซ้ำซ้อน
    if (_isNavigating) return; 
    _isNavigating = true;
    
    // ยกเลิก timer ถ้าผู้ใช้อาจจะแตะหน้าจอก่อนถึง 5 วินาที
    _timer?.cancel(); 

    // ใช้ pushReplacement เพื่อไม่ให้ผู้ใช้กด Back กลับมาที่หน้า Welcome ได้อีก
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(), // เปลี่ยนตรงนี้เป็นหน้าถัดไปของคุณ
      ),
    );
  }

  @override
  void dispose() {
    // ต้องทำลาย timer เสมอเมื่อหน้านี้ถูกปิดเพื่อป้องกัน Memory Leak
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // เมื่อผู้ใช้แตะที่ใดก็ได้บนหน้าจอ ให้เรียกฟังก์ชันเปลี่ยนหน้าทันที
        onTap: _goToNextScreen, 
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            // ใช้ RadialGradient อ่อนๆ เพื่อให้พื้นหลังดูมีมิติคล้ายรูปต้นฉบับ
            gradient: RadialGradient(
              colors: [
                Color(0xFFFCFAEE), // สีครีมสว่างตรงกลาง
                Color(0xFFF0EBE0), // สีครีมที่เข้มขึ้นบริเวณขอบ
              ],
              radius: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // ข้อความ Welcome ตรงกลางหน้าจอ
              const Center(
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5E3B), // สีเขียวเข้ม
                    letterSpacing: 4.0, // เพิ่มช่องไฟให้ตัวอักษร
                    // fontFamily: 'YourCustomFont', // แนะนำให้โหลดฟอนต์ที่คล้ายกันมาใส่ใน pubspec.yaml
                  ),
                ),
              ),
              
              // ข้อความ Develop by 855 ด้านล่าง
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0), // ระยะห่างจากขอบล่าง
                  child: Text(
                    'Develop by 855',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF2C5E3B).withOpacity(0.8), // สีเขียวเดิมที่โปร่งแสงลงเล็กน้อย
                      letterSpacing: 2.0,
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

// -----------------------------------------------------------------
// หน้าจอจำลองสำหรับทดสอบ (คุณสามารถลบส่วนนี้และใส่หน้าของโปรเจคคุณแทนได้)
class NextScreen extends StatelessWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: const Center(child: Text('เข้าสู่แอปพลิเคชันแล้ว!')),
    );
  }
}