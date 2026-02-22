import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_member_screen.dart'; // ดึงหน้าฟอร์มเพิ่มสมาชิกมาใช้

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final Color _backgroundColor = const Color(0xFFF6F4EE);
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryGreen),
        title: Text(
          'รายชื่อสมาชิก (Members)',
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('กรุณาล็อกอินก่อนใช้งาน'))
          : StreamBuilder<QuerySnapshot>(
              // ดึงข้อมูลจาก Sub-collection "members" แบบเรียลไทม์
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('members')
                  .orderBy('createdAt', descending: true) // เรียงจากคนล่าสุดขึ้นก่อน
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
                }

                final members = snapshot.data?.docs ?? [];

                if (members.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีสมาชิกในรายการ',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    var memberData = members[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: _primaryGreen.withOpacity(0.1),
                          radius: 25,
                          child: Icon(
                            memberData['gender'] == 'Female' || memberData['gender'] == 'หญิง'
                                ? Icons.face_3
                                : Icons.face,
                            color: _primaryGreen,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          memberData['name'] ?? 'ไม่ระบุชื่อ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('อายุ: ${memberData['age']} ปี'),
                              Text(
                                'แพ้: ${memberData['allergy']}',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
      // ปุ่มลอยด้านขวาล่างสำหรับกดไปหน้าเพิ่มสมาชิก
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMemberScreen()),
          );
        },
        backgroundColor: _primaryGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'เพิ่มสมาชิก',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}