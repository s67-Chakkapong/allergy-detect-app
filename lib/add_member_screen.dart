import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedAllergy;
  bool _isLoading = false;

  // สีอ้างอิงจาก identify_screen.dart
  final Color _backgroundColor = const Color(0xFFF6F4EE);
  final Color _greenTextColor = const Color(0xFF1B4D3E);
  final Color _greyLabelColor = const Color(0xFF8D8D8D);
  final Color _inputBorderColor = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ฟังก์ชันบันทึกข้อมูลลง Firestore
  Future<void> _saveMember() async {
    if (_nameController.text.trim().isEmpty || 
        _ageController.text.trim().isEmpty || 
        _selectedGender == null || 
        _selectedAllergy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      // บันทึกลง Sub-collection "members" ของ User ปัจจุบัน
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('members')
          .add({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _selectedGender,
        'allergy': _selectedAllergy,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มสมาชิกสำเร็จ!')),
        );
        Navigator.pop(context); // กลับไปหน้า Home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _greenTextColor),
        title: Text(
          'Add member',
          style: TextStyle(color: _greenTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "ข้อมูลสมาชิกใหม่",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _greenTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. ชื่อ
                _buildLabel("ชื่อ (Name)"),
                const SizedBox(height: 8),
                _buildShadowInput(
                  child: TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("กรอกชื่อสมาชิก"),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. อายุ
                _buildLabel("อายุ (Age)"),
                const SizedBox(height: 8),
                _buildShadowInput(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("กรอกอายุ"),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. เพศ
                _buildLabel("เพศ (Gender)"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRadioGender("Male", "ชาย"),
                    const SizedBox(width: 16),
                    _buildRadioGender("Female", "หญิง"),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. ประเภทที่แพ้
                _buildLabel("ประเภทที่แพ้ (Allergy)"),
                const SizedBox(height: 8),
                _buildShadowInput(
                  child: Column(
                    children: [
                      _buildRadioAllergy("Cow's Milk Allergy", "แพ้นมวัว (Cow's Milk Allergy)"),
                      _buildRadioAllergy("Lactose Intolerance", "แพ้น้ำตาลแลคโตส (Lactose Intolerance)"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ปุ่ม Save
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _greenTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "บันทึก (Save)",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Helpers (ดัดแปลงจาก IdentifyScreen) ---
  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _greyLabelColor));
  }

  Widget _buildShadowInput({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _inputBorderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );
  }

  Widget _buildRadioGender(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedGender,
          activeColor: _greenTextColor,
          onChanged: (val) => setState(() => _selectedGender = val),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildRadioAllergy(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _selectedAllergy = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedAllergy,
              activeColor: _greenTextColor,
              onChanged: (val) => setState(() => _selectedAllergy = val),
            ),
            Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13))),
          ],
        ),
      ),
    );
  }
}