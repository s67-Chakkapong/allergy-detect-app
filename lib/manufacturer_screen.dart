import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // 🟢 สำหรับเลือกรูปภาพ

import 'login_screen.dart';

class ManufacturerScreen extends StatefulWidget {
  const ManufacturerScreen({super.key});

  @override
  State<ManufacturerScreen> createState() => _ManufacturerScreenState();
}

class _ManufacturerScreenState extends State<ManufacturerScreen> {
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color backgroundColor = Color(0xFFF9F8F6);

  // Controllers สำหรับหน้าเพิ่มสินค้า
  final _prodIdController = TextEditingController();
  final _prodNameController = TextEditingController();
  final _prodBrandController = TextEditingController();
  final _prodIngredientsController = TextEditingController();

  // Controllers สำหรับหน้าเพิ่มอาการแพ้
  final _dictIdController = TextEditingController();
  final _dictNameController = TextEditingController();
  final _dictAvoidWordsController = TextEditingController();

  bool _isLoading = false;

  // 🟢 ตัวแปรสำหรับเก็บไฟล์รูปภาพที่เลือก
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // 🟢 ฟังก์ชันเลือกรูปจากแกลเลอรี่
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  List<String> _splitTextToArray(String text) {
    if (text.trim().isEmpty) return [];
    return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // 🟢 ฟังก์ชันบันทึกสินค้าลง Firestore (พร้อมอัปโหลดรูป)
  Future<void> _saveProduct() async {
    if (_prodIdController.text.isEmpty || _prodNameController.text.isEmpty) {
      _showSnackBar('กรุณากรอกรหัสและชื่อสินค้า');
      return;
    }

    setState(() => _isLoading = true);
    try {
      String productId = _prodIdController.text.trim();
      String imageUrl = '';

      // 1. ถ้ามีการเลือกรูปภาพ ให้อัปโหลดขึ้น Firebase Storage ก่อน
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images') // สร้างโฟลเดอร์ชื่อนี้ใน Storage
            .child('$productId.jpg'); // ตั้งชื่อไฟล์ตามรหัสสินค้า

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL(); // ดึงลิงก์รูปภาพมาใช้งาน
      }

      // 2. บันทึกข้อมูลข้อความทั้งหมดลง Firestore
      List<String> ingredientsArray = _splitTextToArray(_prodIngredientsController.text);

      await FirebaseFirestore.instance.collection('products').doc(productId).set({
        'name': _prodNameController.text.trim(),
        'brand': _prodBrandController.text.trim(),
        'ingredients': ingredientsArray,
        'imageUrl': imageUrl, // 🟢 บันทึกลิงก์รูปลงฐานข้อมูล
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('บันทึกสินค้าและรูปภาพเรียบร้อยแล้ว!', isSuccess: true);
      
      // ล้างข้อมูลหลังบันทึกเสร็จ
      _prodIdController.clear();
      _prodNameController.clear();
      _prodBrandController.clear();
      _prodIngredientsController.clear();
      setState(() {
        _selectedImage = null; // เคลียร์รูปภาพ
      });

    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAllergyDict() async {
    if (_dictIdController.text.isEmpty || _dictNameController.text.isEmpty) {
      _showSnackBar('กรุณากรอกรหัส (Key) และชื่ออาการแพ้');
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<String> avoidWordsArray = _splitTextToArray(_dictAvoidWordsController.text);

      await FirebaseFirestore.instance
          .collection('allergy_name') // ชื่อ Collection ตาม Rule
          .doc(_dictIdController.text.trim().toLowerCase())
          .set({
        'allergy_name': _dictNameController.text.trim(),
        'avoid_words': avoidWordsArray,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('บันทึกข้อมูลภูมิแพ้เรียบร้อยแล้ว!', isSuccess: true);

      _dictIdController.clear();
      _dictNameController.clear();
      _dictAvoidWordsController.clear();
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Manufacturer Panel',
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'ออกจากระบบ',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: primaryGreen,
            indicatorWeight: 3,
            labelColor: primaryGreen,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "Add Product"),
              Tab(icon: Icon(Icons.medical_information_outlined), text: "Add Allergy"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              title: "ข้อมูลสินค้าใหม่",
              icon: Icons.add_box,
              formFields: [
                // 🟢 ส่วนของ UI สำหรับเลือกรูปภาพ
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400, width: 2, style: BorderStyle.solid),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text("เพิ่มรูปภาพสินค้า", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel("รหัสสินค้า (NFC Tag ID)"),
                _buildInputBox(controller: _prodIdController, hint: 'เช่น 005'),
                const SizedBox(height: 15),
                _buildLabel("ชื่อสินค้า"),
                _buildInputBox(controller: _prodNameController, hint: 'เช่น ช็อกโกแลตนม'),
                const SizedBox(height: 15),
                _buildLabel("แบรนด์/ยี่ห้อ"),
                _buildInputBox(controller: _prodBrandController, hint: 'เช่น ตราหมีน้อย'),
                const SizedBox(height: 15),
                _buildLabel("ส่วนผสมทั้งหมด (คั่นด้วยลูกน้ำ ,)"),
                _buildInputBox(
                  controller: _prodIngredientsController,
                  hint: 'เช่น milk, lactose',
                  maxLines: 4,
                ),
              ],
              onSave: _saveProduct,
              buttonText: "บันทึกข้อมูลสินค้า",
            ),
            _buildTabContent(
              title: "กลุ่มสารก่อภูมิแพ้",
              icon: Icons.coronavirus_outlined,
              formFields: [
                _buildLabel("รหัสอ้างอิง (Doc ID)"),
                _buildInputBox(controller: _dictIdController, hint: 'เช่น cmpa'),
                const SizedBox(height: 15),
                _buildLabel("ชื่อกลุ่มอาการแพ้"),
                _buildInputBox(controller: _dictNameController, hint: 'เช่น แพ้นมวัว (CMPA)'),
                const SizedBox(height: 15),
                _buildLabel("คำต้องห้าม / ส่วนผสมเสี่ยง (คั่นด้วยลูกน้ำ ,)"),
                _buildInputBox(
                  controller: _dictAvoidWordsController,
                  hint: 'เช่น นม, นมผง, เวย์, whey, เคซีน, casein',
                  maxLines: 5,
                ),
              ],
              onSave: _saveAllergyDict,
              buttonText: "บันทึกพจนานุกรม",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required String title,
    required IconData icon,
    required List<Widget> formFields,
    required VoidCallback onSave,
    required String buttonText,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryGreen, size: 28),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
              ],
            ),
            const Divider(height: 30, thickness: 1, color: Color(0xFFEEEEEE)),
            
            ...formFields,
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildInputBox({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}