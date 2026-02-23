import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_member_screen.dart'; 
import 'edit_member_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final Color _backgroundColor = const Color(0xFFF6F4EE);
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  // ----------------------------------------------------------------
  // ฟังก์ชันสำหรับแสดงกล่องยืนยันการลบ และสั่งลบข้อมูลจาก Firebase
  // ----------------------------------------------------------------
  Future<void> _deleteMember(String uid, String memberId, String memberName) async {
    // แสดงกล่อง Dialog ยืนยัน
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบข้อมูลของ "$memberName" ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // ยกเลิก
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), // ยืนยัน
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ลบข้อมูล', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    // ถ้ากด "ยืนยัน" ให้เริ่มทำงานลบ
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('members')
            .doc(memberId) // อ้างอิงถึง ID ของสมาชิกคนนั้นๆ
            .delete(); // คำสั่งลบจาก Firestore

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบสมาชิกเรียบร้อยแล้ว')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการลบ: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

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
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('members')
                  .orderBy('createdAt', descending: true)
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
                    final memberDoc = members[index]; // ดึง Document ของแต่ละคนมา
                    final memberData = memberDoc.data() as Map<String, dynamic>;
                    final memberId = memberDoc.id; // ดึงรหัส ID อัตโนมัติที่ Firebase สร้างให้

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
                        // 🟢 เปลี่ยนจากปุ่มถังขยะอันเดียว เป็น 2 ปุ่มคู่กัน
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. ปุ่มแก้ไข (ดินสอสีน้ำเงิน)
                            IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.blueAccent, size: 30),
                              onPressed: () {
                                // กดแล้วส่งข้อมูลเดิมทั้งหมดไปหน้า EditMemberScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditMemberScreen(
                                      memberId: memberId,
                                      memberData: memberData,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // 2. ปุ่มลบ (ถังขยะสีแดงอันเดิม)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                              onPressed: () {
                                _deleteMember(uid, memberId, memberData['name'] ?? 'สมาชิก');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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