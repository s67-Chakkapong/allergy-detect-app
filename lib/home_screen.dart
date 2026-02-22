import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User data
  String _name = '';
  String _profileImageUrl = '';
  bool _isLoadingUser = true;

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
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _name = data['name'] ?? data['displayName'] ?? 'User';
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
  // Logout
  // ─────────────────────────────────────────
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await GoogleSignIn().signOut(); // sign out Google if used
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // clear all screens from stack
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
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
      await Future.delayed(const Duration(seconds: 1));
      NfcManager.instance.stopSession();
      debugPrint('หยุดโหมดอ่าน NFC แล้ว');
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
          // Profile image — shows real image or default icon
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            backgroundImage: _profileImageUrl.isNotEmpty
                ? NetworkImage(_profileImageUrl)
                : null,
            child: _profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real name from Firestore
                Text(
                  _isLoadingUser ? 'Loading...' : _name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
                const Text(
                  'Good Morning',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'Log out',
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
