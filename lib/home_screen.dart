import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart'; // เพิ่มการอ่าน NFC
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ฟังก์ชันสำหรับเปิดหน้าต่าง Popup พร้อมจัดการ NFC
  void _showNfcDetails(BuildContext context) async {
    // 1. ตรวจสอบว่าเครื่องรองรับ/เปิด NFC หรือไม่
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเปิด NFC ที่การตั้งค่าเครื่องก่อนครับ'),
        ),
      );
      return;
    }

    // 2. เริ่มโหมดอ่าน NFC ทันที
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // เมื่อแตะบัตรสำเร็จ
        debugPrint('ตรวจพบแท็ก: ${tag.data}');

        // ปิด Popup อัตโนมัติเมื่ออ่านสำเร็จ
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('สแกนบัตรสำเร็จ!')));
      },
    );

    // 3. แสดง Popup UI
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "NFC Reading Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1B4332),
                  ),
                ),
                SizedBox(height: 30),
                Icon(Icons.nfc, size: 80, color: Color(0xFF1B4332)),
                SizedBox(height: 20),
                Text("นำบัตรมาแตะที่ด้านหลังโทรศัพท์"),
                SizedBox(height: 10),
                Text(
                  "(แตะข้างนอกเพื่อยกเลิก)",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // 4. เมื่อ Popup ถูกปิด (ไม่ว่าจะสแกนสำเร็จหรือแตะข้างนอก) ให้หยุดโหมดอ่าน NFC
      NfcManager.instance.stopSession();
      debugPrint('หยุดโหมดอ่าน NFC แล้ว');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderProfile(context),
            GestureDetector(
              onTap: () => _showNfcDetails(context),
              child: _buildNfcCard(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Profile ---
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
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- NFC Card ---
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
