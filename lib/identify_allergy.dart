import 'package:flutter/material.dart';

class IdentifyAllergyScreen extends StatefulWidget {
  const IdentifyAllergyScreen({super.key});

  @override
  State<IdentifyAllergyScreen> createState() => _IdentifyAllergyScreenState();
}

class _IdentifyAllergyScreenState extends State<IdentifyAllergyScreen> {
  // State variables
  String? _selectedGender;
  String? _selectedAllergy;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Custom Colors based on the image
  final Color _backgroundColor = const Color(0xFFF6F4EE); // Creamy off-white
  final Color _greenTextColor = const Color(0xFF1B4D3E); // Dark Green
  final Color _greyLabelColor = const Color(0xFF8D8D8D);
  final Color _inputBorderColor = const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(), // Pushes the card to the center vertically
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
                          fontFamily: 'Sans', // Use system font or specify one
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Name Input
                    _buildLabel("Name"),
                    const SizedBox(height: 8),
                    _buildShadowInput(
                      child: TextField(
                        controller: _nameController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age and Gender Row
                    Row(
                      children: [
                        // Age Section
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

                        // Gender Section
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Gender"),
                              const SizedBox(height: 8),
                              _buildShadowInput(
                                child: Container(
                                  height:
                                      48, // Match standard text field height
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

                    // Allergy Selector
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
                            "Cow's Milk Allergy",
                            "แพ้นมวัว (Cow's Milk Allergy)",
                          ),
                          // A subtle divider line could go here if strictly needed, but image doesn't clearly show one
                          _buildAllergyOption(
                            "Lactose Intolerance",
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
                      onPressed: () {
                        // Handle Back
                        Navigator.of(context).pop();
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
                      textDirection:
                          TextDirection.rtl, // To put icon on the right
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle Next
                        },
                        icon: Icon(
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

  // --- WIDGET BUILDER HELPERS ---

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

  // Wraps content in a container with a subtle shadow and rounded corners (Neumorphic-ish look)
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
            activeColor: Colors.grey, // The image shows grey filled circles
            onChanged: (val) {
              setState(() {
                _selectedGender = val;
              });
            },
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
      onTap: () {
        setState(() {
          _selectedAllergy = value;
        });
      },
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
                onChanged: (val) {
                  setState(() {
                    _selectedAllergy = val;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12, // Slightly smaller to fit the text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
