import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ตั้งสีพื้นหลังครีมอ่อนๆ ตามดีไซน์
      backgroundColor: const Color(0xFFF9F8F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderProfile(context), // ส่วนหัวโปรไฟล์
            _buildNfcCard(), // ส่วนบัตร NFC
            // ในอนาคตคุณสามารถเพิ่ม _buildMenu() ตรงนี้ได้ครับ
          ],
        ),
      ),
    );
  }

  // --- 1. ส่วน Header Profile ---
  Widget _buildHeaderProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // รูป Profile
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            ),
          ),
          const SizedBox(width: 12),

          // ข้อมูลชื่อและคำทักทาย
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ปุ่มไอคอนแจ้งเตือน (Help)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Colors.grey),
          ),
          // ปุ่ม Logout
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- 2. ส่วน NFC Card ---
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
        children: [
          // ไอคอน NFC
          const Icon(Icons.nfc, size: 80, color: Color(0xFF1B4332)),
          const SizedBox(height: 20),

          // ข้อความภาษาไทย
          const Text(
            'นำโทรศัพท์ของคุณไปสัมผัสกับ NFC Tag',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 8),

          // ข้อความภาษาอังกฤษ
          const Text(
            'Bring your phone close to the NFC tag.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
