import 'dart:ui';
import 'dart:convert'; // สำหรับแปลงข้อมูลที่อ่านจาก NFC
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart'; //
import 'package:app_settings/app_settings.dart'; // สำหรับเปิดหน้าตั้งค่า NFC
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ฟังก์ชันสำหรับเช็ค NFC และเปิดหน้าต่างสแกน
  void _showNfcDetails(BuildContext context) async {
    // 1. ตรวจสอบว่าเครื่องเปิด NFC หรือไม่
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      // ✅ ถ้าปิดอยู่ ให้เด้งไปหน้า Settings ของมือถือ (Redmi Note 9 Pro)
      _showNfcSettingsDialog(context);
      return;
    }

    // 2. เริ่มโหมดอ่าน NFC ทันที
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef != null && ndef.cachedMessage != null) {
            var record = ndef.cachedMessage!.records.first;
            String allergyKey = utf8.decode(record.payload.sublist(3));

            // 1. หยุดการอ่านซ้ำทันที (ลดอาการ Bounce)
            // เราจะไม่สั่ง stopSession ทันทีที่นี่ แต่จะให้ Dialog ปิดก่อน

            if (mounted) {
              // 2. ปิด Popup UI ของเราก่อน
              Navigator.of(context, rootNavigator: true).pop();

              // 3. หน่วงเวลาเล็กน้อยเพื่อให้ Android คลายสถานะจากบัตรใบเดิม
              await Future.delayed(const Duration(milliseconds: 500));

              // 4. นำทางไปหน้าแจ้งเตือน
              if (mounted) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllergyWarningScreen(allergyType: allergyKey),
                  ),
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error: $e');
        } finally {
          // สำคัญ: ไม่ต้องสั่ง stopSession ที่นี่ เพราะเราสั่งใน .then() ของ showDialog แล้ว
        }
      },
    );

    // 3. แสดง Popup UI พร้อมเอฟเฟกต์เบลอ (BackdropFilter)
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.6,
      ), // ปรับสีพื้นหลังให้เข้มขึ้นเพื่อให้เบลอชัด
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ), // ปรับค่าความมัวให้เห็นชัดเจน
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
    ).then((_) async {
      // รอสักครู่ก่อนหยุด Session เพื่อให้การแตะบัตรสิ้นสุดลงจริงๆ
      await Future.delayed(const Duration(seconds: 1));
      NfcManager.instance.stopSession();
      debugPrint('หยุดโหมดอ่าน NFC แล้ว');
    });
  }

  // ฟังก์ชันแจ้งเตือนให้เปิด NFC ในเครื่อง
  void _showNfcSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("NFC ถูกปิดอยู่"),
        content: const Text(
          "กรุณาเปิดใช้งาน NFC เพื่อทำการสแกนบัตรสารก่อภูมิแพ้ครับ",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // เปิดหน้าตั้งค่า NFC ของ Android โดยตรง
              AppSettings.openAppSettings(type: AppSettingsType.nfc);
            },
            child: const Text("ไปที่การตั้งค่า"),
          ),
        ],
      ),
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
            GestureDetector(
              onTap: () => _showNfcDetails(context),
              child: _buildNfcCard(),
            ),
          ],
        ),
      ),
    );
  }

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
            'แตะเพื่อเริ่มการสแกน NFC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap to start scanning NFC tag.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// --- หน้าจอแจ้งเตือนเมื่อพบสารก่อภูมิแพ้ ---
class AllergyWarningScreen extends StatelessWidget {
  final String allergyType;
  const AllergyWarningScreen({super.key, required this.allergyType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50], // พื้นหลังสีแดงแจ้งเตือน
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 120,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                "ตรวจพบสารก่อภูมิแพ้!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "อาหารนี้มีส่วนประกอบของ: $allergyType",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "รับทราบและระมัดระวัง",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
