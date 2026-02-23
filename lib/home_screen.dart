import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_screen.dart';
import 'identify_screen.dart';
import 'member_list_screen.dart';
import 'result_screen.dart'; // 🟢 เพิ่มการเชื่อมต่อไปหน้าผลลัพธ์อันใหม่

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _profileImageUrl = '';
  bool _isLoadingUser = true;

  static const Color primaryGreen = Color(0xFF1B4D3E);
  static const Color bgCream = Color(0xFFF7F5EE);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ─────────────────────────────────────────
  // Load user data from Firestore
  // ─────────────────────────────────────────
  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.server)); // 👈 skip cache

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _name = data['name'] ?? '';
          _profileImageUrl = data['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoadingUser = false);
    }
  }

  // ─────────────────────────────────────────
  // Logout — sign out and go to LoginScreen
  // ─────────────────────────────────────────
  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _processNfcTag(String nfcProductId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryGreen)),
    );

    try {
      final productDoc = await FirebaseFirestore.instance.collection('products').doc(nfcProductId).get();

      if (!productDoc.exists) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลสินค้านี้ในระบบ')));
        return;
      }

      // ... โค้ดก่อนหน้า ...
      List<String> productIngredients = List<String>.from(
        productDoc.data()?['ingredients'] ?? productDoc.data()?['allergens'] ?? []
      );
      String productName = productDoc.data()?['name'] ?? 'สินค้าไม่ทราบชื่อ';
      String imageUrl = productDoc.data()?['imageUrl'] ?? ''; // 🟢 เพิ่มบรรทัดนี้! ดึงลิงก์รูปมาเก็บไว้

      final uid = FirebaseAuth.instance.currentUser?.uid;
      // ... โค้ดส่วนอื่นๆ ที่เช็คคนแพ้อาหาร ...
      if (uid == null) return;

      bool isOverallSafe = true;
      List<String> warningMessages = [];
      Set<String> allAvoidWords = {}; 
      
      // 🟢 ตัวแปรสำหรับคัดแยกคนทานได้/ไม่ได้
      List<String> safeMembers = [];
      List<String> unsafeMembers = [];

      // =========================================================
      // 1. ตรวจสอบข้อมูลแพ้อาหารของ "ตัวเอง (Main User)"
      // =========================================================
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String myName = userDoc.data()?['name'] ?? 'คุณ';
        String displayName = '$myName (ฉัน)'; // 🟢 เพิ่มตัวแปรใหม่ เติมคำว่า (ฉัน) เข้าไป
        String myAllergyKey = userDoc.data()?['allergy'] ?? ''; 
        bool isMySafe = true; // สถานะความปลอดภัยของตัวเอง

        if (myAllergyKey.isNotEmpty) {
          final dictDoc = await FirebaseFirestore.instance.collection('allergy_name').doc(myAllergyKey).get();
          if (dictDoc.exists) {
            List<dynamic> badWords = dictDoc.data()?['avoid_words'] ?? [];
            for (var word in badWords) allAvoidWords.add(word.toString());

            for (String ingredient in productIngredients) {
              for (String badWord in badWords) {
                if (ingredient.toLowerCase().contains(badWord.toLowerCase())) {
                  isOverallSafe = false;
                  isMySafe = false;
                  // 🟢 เปลี่ยนมาใช้ displayName เพื่อให้โชว์คำว่า (ฉัน) ตรงข้อความเตือน
                  warningMessages.add('- $displayName แพ้ "$ingredient"'); 
                  break; 
                }
              }
              if (!isMySafe) break; // เจอ 1 อย่างที่แพ้ ก็ถือว่ากินไม่ได้แล้ว
            }
          }
        }
        
        // คัดแยกชื่อตัวเอง
        if (isMySafe) {
          safeMembers.add(displayName); // 🟢 เปลี่ยนมาใช้ displayName 
        } else {
          unsafeMembers.add(displayName); // 🟢 เปลี่ยนมาใช้ displayName 
        }
      }

      // =========================================================
      // 2. ตรวจสอบข้อมูลแพ้อาหารของ "ครอบครัว (Members)"
      // =========================================================
      final membersSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).collection('members').get();
      
      for (var member in membersSnapshot.docs) {
        String memberName = member.data()['name'] ?? 'สมาชิก';
        String allergyKey = member.data()['allergy'] ?? ''; 
        bool isMemberSafe = true;

        if (allergyKey.isNotEmpty) {
          final dictDoc = await FirebaseFirestore.instance.collection('allergy_name').doc(allergyKey).get();
          if (dictDoc.exists) {
            List<dynamic> badWords = dictDoc.data()?['avoid_words'] ?? [];
            for (var word in badWords) allAvoidWords.add(word.toString());
            
            for (String ingredient in productIngredients) {
              for (String badWord in badWords) {
                if (ingredient.toLowerCase().contains(badWord.toLowerCase())) {
                  isOverallSafe = false;
                  isMemberSafe = false;
                  warningMessages.add('- คุณ "$memberName" แพ้ "$ingredient"');
                  break; 
                }
              }
              if (!isMemberSafe) break;
            }
          }
        }

        // คัดแยกชื่อสมาชิกครอบครัว
        if (isMemberSafe) {
          safeMembers.add(memberName);
        } else {
          unsafeMembers.add(memberName);
        }
      }

      // ส่งผลลัพธ์ไปแสดงหน้า ResultScreen
      // ส่งผลลัพธ์ไปแสดงหน้า ResultScreen
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              isSafe: isOverallSafe,
              productName: productName,
              ingredients: productIngredients,
              warningMessages: warningMessages.toSet().toList(),
              userAvoidWords: allAvoidWords.toList(),
              safeMembers: safeMembers,     
              unsafeMembers: unsafeMembers, 
              imageUrl: imageUrl, // 🟢 เพิ่มบรรทัดนี้! เพื่อส่งลิงก์รูปไปให้หน้านั้น
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  // ─────────────────────────────────────────
  // 🟢 สำหรับนักพัฒนา: กล่องกรอกรหัสสินค้าจำลอง NFC
  // ─────────────────────────────────────────
  void _showManualEntryDialog() {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange),
              SizedBox(width: 10),
              Text('ทดสอบระบบ (Debug)'),
            ],
          ),
          content: TextField(
            controller: idController,
            decoration: const InputDecoration(
              hintText: 'ใส่รหัสสินค้า เช่น 005',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () {
                final testId = idController.text.trim();
                Navigator.pop(context); // ปิดกล่องข้อความ
                if (testId.isNotEmpty) {
                  _processNfcTag(testId); // โยนรหัสที่กรอกไปให้ระบบประมวลผลทันที!
                }
              },
              child: const Text('ตรวจสอบ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // NFC (เปิดระบบอ่านและโชว์หน้าต่างเบลอ)
  // ─────────────────────────────────────────
  void _showNfcDetails(BuildContext context) async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      _showNfcSettingsDialog(context);
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef != null && ndef.cachedMessage != null) {
            var record = ndef.cachedMessage!.records.first;
            
            // 🟢 อ่านข้อมูลเป็นรหัสสินค้าแทน
            String nfcPayload = utf8.decode(record.payload.sublist(3));
            String productId = nfcPayload.trim();

            await NfcManager.instance.stopSession(); // ปิดระบบอ่านหลังได้ข้อมูล

            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // ปิดหน้าต่าง Popup เบลอๆ
              await Future.delayed(const Duration(milliseconds: 300)); // หน่วงเวลาเล็กน้อยให้ปิดสนิท

              // 🟢 ส่งรหัสไปประมวลผลต่อ
              if (mounted) {
                _processNfcTag(productId);
              }
            }
          }
        } catch (e) {
          await NfcManager.instance.stopSession();
          debugPrint('Error: $e');
        }
      },
    );

    // หน้าต่าง Popup แจ้งเตือนให้แตะ NFC (UI เดิมของคุณ)
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                    color: primaryGreen,
                  ),
                ),
                SizedBox(height: 30),
                Icon(Icons.nfc, size: 80, color: primaryGreen),
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
      await Future.delayed(const Duration(seconds: 1));
      NfcManager.instance.stopSession();
    });
  }

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
              AppSettings.openAppSettings(type: AppSettingsType.nfc);
            },
            child: const Text("ไปที่การตั้งค่า"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showNfcDetails(context),
                  child: _buildNfcCard(),
                ),
                
                // 🟢 เพิ่มปุ่ม Debug ตรงนี้ครับ (ใต้การ์ด NFC)
                Center(
                  child: TextButton.icon(
                    onPressed: _showManualEntryDialog,
                    icon: const Icon(Icons.keyboard, color: Colors.grey, size: 18),
                    label: const Text(
                      'ทดสอบกรอกรหัสสินค้าเอง (Debug)',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
                // 🟢 จบส่วนที่เพิ่ม

                const SizedBox(height: 15), // ปรับลดระยะห่างลงนิดหน่อย
                _buildMenuSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryGreen, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF8FA895),
            child: _profileImageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _profileImageUrl,
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 28,
                        color: primaryGreen,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 28, color: primaryGreen),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoadingUser ? 'Loading...' : _name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Good Morning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ],
        ),
        const Spacer(),
        // 🔴 เอาปุ่ม live_help_outlined ออกไปแล้ว เหลือแค่ปุ่ม Logout
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.black87, size: 28),
          tooltip: 'Log out',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // NFC Card
  // ─────────────────────────────────────────
  Widget _buildNfcCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x804F6F52),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rss_feed, color: Colors.white, size: 18),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.contactless_outlined,
                  size: 50,
                  color: Colors.black87,
                ),
                const SizedBox(height: 15),
                const Text(
                  'นำโทรศัพท์ของคุณไปสัมผัสกับ NFC Tag',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bring your phone close to the NFC tag.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Menu Section
  // ─────────────────────────────────────────
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMenuButton(
                icon: Icons.person_pin,
                title: 'Edit profile',
                subtitle: 'แก้ไขข้อมูลส่วนตัว',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdentifyAllergyScreen(),
                    ),
                  );
                  _loadUserData();
                },
              ),
              const SizedBox(width: 15),
              _buildMenuButton(
                icon: Icons.person_add_alt_1,
                title: 'Add member',
                subtitle: 'เพิ่มสมาชิก',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberListScreen(),
                    ),
                  );
                },
              ),
              // 🔴 ลบปุ่ม History และ Bookmark ออกไปแล้ว
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}