import 'dart:async';
import 'package:flutter/material.dart';
import 'register_screen.dart'; // อย่าลืม import หน้านี้

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // ... (ส่วนของ Timer และตัวแปร _isNavigating เหมือนเดิม ไม่ต้องแก้) ...
  Timer? _timer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _goToNextScreen);
  }

  void _goToNextScreen() {
    if (_isNavigating) return;
    _isNavigating = true;
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  // ... (จบบนของ Timer) ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToNextScreen,

        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              // จุดศูนย์กลาง: ให้อยู่ตรงกลาง
              center: Alignment.center,
              // รัศมี: ตั้งค่าประมาณ 1.2 - 1.5 เพื่อให้การไล่สีดูนุ่มนวลกระจายทั่วจอ
              radius: 0.5,
              colors: [
                Color(0xFFE8DFCA), // สีที่ 1: ครีมสว่าง (อยู่ตรงกลาง)
                Color(0xFFF5EFE6), // สีที่ 2: ครีมเข้มขึ้น/เบจ (อยู่ขอบๆ)
              ],
              // stops: [0.0, 1.0], // ไม่จำเป็นต้องใส่ถ้าต้องการให้ไล่สีสม่ำเสมอกัน
            ),
          ),

          child: Stack(
            children: [
               const Center(
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5E3B), 
                    letterSpacing: 4.0,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Develop by 855',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C5E3B), 
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