import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isSafe;
  final String productName;
  final List<String> ingredients;
  final List<String> warningMessages;
  final List<String> userAvoidWords; // เรายังต้องใช้ตัวแปรนี้เพื่อเอามาเช็คคำ
  final List<String> safeMembers;
  final List<String> unsafeMembers;

  const ResultScreen({
    super.key,
    required this.isSafe,
    required this.productName,
    required this.ingredients,
    required this.warningMessages,
    required this.userAvoidWords,
    required this.safeMembers,
    required this.unsafeMembers,
  });

  // 🟢 ฟังก์ชันใหม่สำหรับสร้างข้อความส่วนผสมพร้อมไฮไลท์สีแดง
  Widget _buildHighlightedIngredients(List<String> ingredients, List<String> avoidWords) {
    if (ingredients.isEmpty) {
      return const Text('ไม่ระบุส่วนผสม', style: TextStyle(fontSize: 14));
    }

    List<InlineSpan> spans = [];
    for (int i = 0; i < ingredients.length; i++) {
      String ingredient = ingredients[i];
      
      // เช็คว่าส่วนผสมนี้มีคำต้องห้ามซ่อนอยู่หรือไม่
      bool isDangerous = avoidWords.any((avoidWord) => 
          ingredient.toLowerCase().contains(avoidWord.toLowerCase()));

      if (isDangerous) {
        // 🔴 ถ้าอันตราย: ให้ขีดเส้นใต้สีแดงและทำตัวหนา
        spans.add(TextSpan(
          text: ingredient,
          style: const TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationThickness: 2.0, // เพิ่มความหนาของเส้น
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        // ⚪ ถ้าปลอดภัย: แสดงตัวหนังสือปกติ
        spans.add(TextSpan(text: ingredient));
      }

      // เติมลูกน้ำ (,) คั่นระหว่างคำ (ยกเว้นคำสุดท้าย)
      if (i < ingredients.length - 1) {
        spans.add(const TextSpan(text: ", "));
      }
    }

    // ใช้ RichText เพื่อแสดงข้อความที่มีหลายสไตล์ผสมกัน
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isSafe ? Colors.green[700]! : Colors.red[700]!;
    final Color bgColor = const Color(0xFFF9F8F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/3753/3753238.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 30),

              // การ์ด 1: สถานะความปลอดภัย
              _buildCard(
                borderColor: isSafe ? Colors.transparent : Colors.red.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSafe
                          ? 'ผลิตภัณฑ์นี้สามารถรับประทานได้'
                          : 'ผลิตภัณฑ์นี้ไม่ควรรับประทาน',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSafe
                          ? 'ผลิตภัณฑ์ "$productName" ไม่มีส่วนผสมที่คุณหรือสมาชิกในครอบครัวแพ้'
                          : 'ระวัง! ผลิตภัณฑ์ "$productName" มีส่วนผสมที่ทำให้คุณแพ้ได้ ควรหลีกเลี่ยง\n\n${warningMessages.join('\n')}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 🟢 การ์ด 2: ส่วนผสม (ปรับปรุงใหม่)
              _buildCard(
                borderColor: isSafe ? Colors.transparent : Colors.red.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ส่วนผสม (Ingredients)',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // ❌ ลบส่วนที่แสดง "สิ่งที่คุณต้องหลีกเลี่ยง" ออกไปแล้ว
                    
                    Text(
                      '📦 ส่วนผสมในผลิตภัณฑ์ "$productName":',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    // 🟢 เรียกใช้ฟังก์ชันใหม่เพื่อแสดงส่วนผสมแบบมีไฮไลท์
                    _buildHighlightedIngredients(ingredients, userAvoidWords),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // การ์ด 3: สรุปสถานะสมาชิก
              _buildCard(
                borderColor: isSafe ? Colors.transparent : Colors.red.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สรุปสถานะสมาชิก',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (safeMembers.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Text('ทานได้:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[600])),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0, top: 4.0, bottom: 8.0),
                        child: Text(safeMembers.join(', '), style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ),
                    ],

                    if (unsafeMembers.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('ทานไม่ได้ (เสี่ยงแพ้):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0, top: 4.0),
                        child: Text(unsafeMembers.join(', '), style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // ปุ่ม OK
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.keyboard_double_arrow_right, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color borderColor = Colors.transparent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2.0), // เพิ่มความหนาขอบเล็กน้อย
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}