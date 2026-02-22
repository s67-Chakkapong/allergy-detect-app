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
          .get(const GetOptions(source: Source.server));

      if (doc.exists) {
        final data = doc.data()!;
        final name = data['name'] ?? '';
        final displayName = data['displayName'] ?? '';
        final imageUrl = data['profileImageUrl'] ?? '';

        setState(() {
          // Use name if filled, fallback to displayName, fallback to email
          _name = name.isNotEmpty
              ? name
              : displayName.isNotEmpty
              ? displayName
              : FirebaseAuth.instance.currentUser?.email ?? 'User';

          _profileImageUrl = imageUrl;
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

  // ─────────────────────────────────────────
  // NFC
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
            String allergyKey = utf8.decode(record.payload.sublist(3));

            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              await Future.delayed(const Duration(milliseconds: 500));

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
        }
      },
    );

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
                const SizedBox(height: 35),
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
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.live_help_outlined,
            color: Colors.black87,
            size: 28,
          ),
        ),
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
                  // 🟢 เปลี่ยนมาเปิดหน้า MemberListScreen แทน
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              _buildMenuButton(
                icon: Icons.history,
                title: 'History',
                subtitle: 'ประวัติการใช้งาน',
                onTap: () {},
              ),
              const SizedBox(width: 15),
              _buildMenuButton(
                icon: Icons.bookmark,
                title: 'Bookmark',
                subtitle: 'รายการที่บันทึกไว้',
                onTap: () {},
              ),
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

// ─────────────────────────────────────────
// Allergy Warning Screen
// ─────────────────────────────────────────
class AllergyWarningScreen extends StatelessWidget {
  final String allergyType;
  const AllergyWarningScreen({super.key, required this.allergyType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
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
