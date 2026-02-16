import 'package:flutter/material.dart';

class IdentifyAllergyScreen extends StatefulWidget {
  const IdentifyAllergyScreen({super.key});

  @override
  State<IdentifyAllergyScreen> createState() => _IdentifyAllergyScreenState();
}

class _IdentifyAllergyScreenState extends State<IdentifyAllergyScreen> {
  String? _selectedAllergy; // 'milk' or 'lactose'

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5A3A);
    const cardBg = Color(0xFFF6F3EF);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: [
            // (optional) top small text like screenshot
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Identify(Parent) Added screen',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Identify allergies',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Name
                          const _FieldLabel('Name'),
                          const SizedBox(height: 8),
                          const _InputBox(hintText: '', obscureText: false),
                          const SizedBox(height: 18),

                          // Allergy + ?
                          Row(
                            children: [
                              const Expanded(child: _FieldLabel('Allergy')),
                              const SizedBox(width: 8),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Radio card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  value: 'milk',
                                  groupValue: _selectedAllergy,
                                  onChanged: (v) => setState(() => _selectedAllergy = v),
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("แพ้นมวัว (Cow's Milk Allergy)"),
                                ),
                                const Divider(height: 1),
                                RadioListTile<String>(
                                  value: 'lactose',
                                  groupValue: _selectedAllergy,
                                  onChanged: (v) => setState(() => _selectedAllergy = v),
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('แพ้น้ำตาลแลคโตส (Lactose Intolerance)'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Member
                          const _FieldLabel('Member'),
                          const SizedBox(height: 10),

                          // Members list card
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'List of members',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.person_add_alt_1),
                                      tooltip: 'Add member',
                                    ),
                                  ],
                                ),
                                const Divider(height: 1),

                                _memberRow('เด็กหญิงฟ้า'),
                                const Divider(height: 1),
                                _memberRow('เด็กชายกร'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom nav (Back / Next)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('≪ Back'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Next ≫'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.account_circle, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const _InputBox({
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
