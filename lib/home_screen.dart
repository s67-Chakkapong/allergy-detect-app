import 'dart:ui'; // ต้อง import ตัวนี้เพื่อใช้ ImageFilter.blur
import 'package:allergy_detect_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ฟังก์ชันสำหรับเปิดหน้าต่าง Popup พร้อมเบลอพื้นหลัง
  void _showNfcDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1), // สีของพื้นหลังที่บังอยู่
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ), // ปรับค่าความเบลอที่นี่
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min, // ให้ขนาดพอดีกับเนื้อหา
              children: [
                const Text(
                  "NFC Card Detail",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.nfc, size: 80, color: Color(0xFF1B4332)),
                const SizedBox(height: 20),
                const Text("รายละเอียดข้อมูลภายใน Tag NFC..."),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderProfile(context),
            // หุ้มบัตร NFC ด้วย GestureDetector เพื่อให้กดได้
            GestureDetector(
              onTap: () => _showNfcDetails(context),
              child: _buildNfcCard(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Profile (เหมือนเดิม) ---
  Widget _buildHeaderProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'เด็กชายตรงเองครับ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
                Text(
                  'Good Morning',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.help_outline, color: Colors.grey),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- NFC Card (เหมือนเดิม) ---
  Widget _buildNfcCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.nfc, size: 80, color: Color(0xFF1B4332)),
          SizedBox(height: 20),
          Text(
            'นำโทรศัพท์ของคุณไปสัมผัสกับ NFC Tag',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bring your phone close to the NFC tag.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
