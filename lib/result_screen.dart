import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isSafe;
  final String productName;
  final List<String> ingredients;
  final List<String> warningMessages;

  const ResultScreen({
    super.key,
    required this.isSafe,
    required this.productName,
    required this.ingredients,
    required this.warningMessages,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามสถานะความปลอดภัย
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
              // รูปไอคอนสินค้า (ใช้ไอคอนขวดนมชั่วคราวตามภาพเรฟ)
              Center(
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/3753/3753238.png', // เปลี่ยนเป็น URL รูปลงโปรเจคทีหลังได้
                  height: 100,
                ),
              ),
              const SizedBox(height: 30),

              // การ์ด 1: สถานะความปลอดภัย
              _buildCard(
                borderColor: isSafe ? Colors.transparent : Colors.red.withOpacity(0.3),
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

              // การ์ด 2: ส่วนผสม
              _buildCard(
                borderColor: isSafe ? Colors.transparent : Colors.blueAccent, // ขอบสีน้ำเงินตามภาพ Bad Result
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ส่วนผสม',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ingredients.join(', '),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // การ์ด 3: โภชนาการ (ดัมมี่ไว้ก่อน)
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'โภชนาการ',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('ข้อมูลโภชนาการจะแสดงที่นี่', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              const Spacer(),

              // ปุ่ม OK ด้านล่าง
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

  // ตัวช่วยสร้างการ์ดที่มีเงาและขอบมน
  Widget _buildCard({required Widget child, Color borderColor = Colors.transparent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1.5),
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