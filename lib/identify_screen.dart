import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IdentifyAllergyScreen extends StatefulWidget {
  const IdentifyAllergyScreen({super.key});

  @override
  State<IdentifyAllergyScreen> createState() => _IdentifyAllergyScreenState();
}

class _IdentifyAllergyScreenState extends State<IdentifyAllergyScreen> {
  // State variables
  String? _selectedGender;
  String? _selectedAllergy;
  String _existingImageUrl = '';
  bool _isLoading = false;
  bool _isFetching = true;
  File? _profileImage;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Custom Colors
  final Color _backgroundColor = const Color(0xFFF6F4EE);
  final Color _greenTextColor = const Color(0xFF1B4D3E);
  final Color _greyLabelColor = const Color(0xFF8D8D8D);
  final Color _inputBorderColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Pick image from camera or gallery
  // ─────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.camera, // or gallery
                  imageQuality: 70,
                  maxWidth: 800, // ✅ add this
                  maxHeight: 800, // ✅ add this
                );
                if (picked != null) {
                  setState(() => _profileImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (picked != null) {
                  setState(() => _profileImage = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Upload image to Firebase Storage
  // ─────────────────────────────────────────
  Future<String?> _uploadImage(String uid) async {
    if (_profileImage == null) return null;

    try {
      const cloudName = 'dvekcyzya';
      const uploadPreset = 'mpn7oa1x';

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'profile_${uid}_$timestamp';

      // ✅ Read as bytes instead of path (fixes Android cache issue)
      final bytes = await _profileImage!.readAsBytes();

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = publicId
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'profile_$uid.jpg', // ✅ explicit filename with extension
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      debugPrint('Cloudinary response: $jsonData');

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        debugPrint('❌ Cloudinary error: $jsonData');
        return null;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // Load existing data from Firestore
  // ─────────────────────────────────────────
  Future<void> _loadExistingData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age'] != 0 ? data['age'].toString() : '';
          _selectedGender = (data['gender'] as String?)?.isEmpty == true
              ? null
              : data['gender'];
          _selectedAllergy = (data['allergy'] as String?)?.isEmpty == true
              ? null
              : data['allergy'];
          _existingImageUrl = data['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // ─────────────────────────────────────────
  // Validate, upload image, save and navigate
  // ─────────────────────────────────────────
  Future<void> _saveAndNext() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      _showSnackBar('Please enter your age');
      return;
    }
    if (_selectedGender == null) {
      _showSnackBar('Please select your gender');
      return;
    }
    if (_selectedAllergy == null) {
      _showSnackBar('Please select your allergy type');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Upload profile image first and get download URL
      final imageUrl = await _uploadImage(uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _selectedGender,
        'allergy': _selectedAllergy,
        'profileImageUrl': ?imageUrl,
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HomeScreen(), // 👈 replace with your HomeScreen
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────
  // Save partial progress when user goes back
  // ─────────────────────────────────────────
  Future<void> _savePartialProgress() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _selectedGender ?? '',
        'allergy': _selectedAllergy ?? '',
        'isProfileComplete': false,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving partial progress: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),

              // --- MAIN CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        "Identify allergies",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _greenTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Profile Image Picker ──
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!) as ImageProvider
                              : (_existingImageUrl.isNotEmpty
                                    ? NetworkImage(_existingImageUrl)
                                    : null),
                          child:
                              (_profileImage == null &&
                                  _existingImageUrl.isEmpty)
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap to add photo',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Name Input ──
                    _buildLabel("Name"),
                    const SizedBox(height: 8),
                    _buildShadowInput(
                      child: TextField(
                        controller: _nameController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Age and Gender Row ──
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Age"),
                              const SizedBox(height: 8),
                              _buildShadowInput(
                                child: TextField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Gender"),
                              const SizedBox(height: 8),
                              _buildShadowInput(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      _buildRadioItem("Male", "Male"),
                                      const SizedBox(width: 10),
                                      _buildRadioItem("Female", "Female"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Allergy Selector ──
                    Row(
                      children: [
                        _buildLabel("Allergy"),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildShadowInput(
                      child: Column(
                        children: [
                          _buildAllergyOption(
                            "cmpa",
                            "แพ้นมวัว (Cow's Milk Allergy)",
                          ),
                          _buildAllergyOption(
                            "lactose_intolerance",
                            "แพ้น้ำตาลแลคโตส (Lactose Intolerance)",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- BOTTOM NAVIGATION ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await _savePartialProgress();
                        if (mounted) Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Colors.grey[400],
                      ),
                      label: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _saveAndNext,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              )
                            : Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.grey[400],
                              ),
                        label: Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _greyLabelColor,
      ),
    );
  }

  Widget _buildShadowInput({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _inputBorderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );
  }

  Widget _buildRadioItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Radio<String>(
            value: value,
            groupValue: _selectedGender,
            activeColor: Colors.grey,
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAllergyOption(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _selectedAllergy = value),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<String>(
                value: value,
                groupValue: _selectedAllergy,
                activeColor: Colors.grey,
                onChanged: (val) => setState(() => _selectedAllergy = val),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
