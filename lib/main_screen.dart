import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // กำหนดสีหลักที่ใช้ในหน้านี้
    const Color primaryGreen = Color(0xFF1B4D3E); // สีเขียวเข้ม
    const Color bgCream = Color(0xFFF7F5EE); // สีครีมพื้นหลัง (ปรับให้อ่อนลงคล้ายรูป)

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------------
                // 1. ส่วน Header (โปรไฟล์ + ปุ่มช่วยเหลือ + ปุ่มออก)
                // ---------------------------------------------------------
                Row(
                  children: [
                    // รูปโปรไฟล์
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGreen, width: 1.5),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF8FA895), // สีเขียวอ่อนพื้นหลังรูป
                        child: Icon(Icons.person, size: 28, color: primaryGreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ชื่อและคำทักทาย
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'เด็กชายตรงเองครับ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // ปุ่ม Live Help (คล้ายๆ กล่องข้อความมีเครื่องหมายคำถาม)
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.live_help_outlined, color: Colors.black87, size: 28),
                    ),
                    // ปุ่ม Logout
                    IconButton(
                      onPressed: () {
                         Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.black87, size: 28),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ---------------------------------------------------------
                // 2. ส่วน NFC Card (เอาขอบฟ้าออก ปรับเงาให้นุ่มขึ้น)
                // ---------------------------------------------------------
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x804F6F52), // เงาสีดำอ่อนๆ
                        spreadRadius: 2,
                        blurRadius: 15, // ฟุ้งๆ ดูเป็นธรรมชาติ
                        offset: const Offset(0, 8), // เลื่อนเงาลงมาด้านล่าง
                      ),
                    ],

                  ),
                  child: Stack(
                    children: [
                      // ไอคอนสัญญาณมุมซ้ายบน
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.rss_feed, color: Colors.white, size: 18),
                        ),
                      ),
                      // เนื้อหาตรงกลาง
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // คุณสามารถเปลี่ยน Icons.contactless เป็น Image.asset('path/to/image.png') เพื่อใช้รูปมือถือแตะตามแบบได้ครับ
                            const Icon(Icons.contactless_outlined, size: 50, color: Colors.black87), 
                            const SizedBox(height: 15),
                            const Text(
                              'นำโทรศัพท์ของคุณไปสัมผัสกับ NFC Tag',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bring your phone close to the NFC tag.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // ---------------------------------------------------------
                // 3. ส่วน Menu (4 ปุ่มเรียงกัน)
                // ---------------------------------------------------------
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 15),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMenuButton(Icons.person_pin, 'Edit profile', 'แก้ไขข้อมูลส่วนตัว'),
                      const SizedBox(width: 15), // เพิ่มช่องว่างระหว่างปุ่ม
                      _buildMenuButton(Icons.person_add_alt_1, 'Add member', 'เพิ่มสมาชิก'),
                      const SizedBox(width: 15),
                      _buildMenuButton(Icons.history, 'History', 'ประวัติการใช้งาน'),
                      const SizedBox(width: 15),
                      _buildMenuButton(Icons.bookmark, 'Bookmark', 'รายการที่บันทึกไว้'),
                      const SizedBox(width: 15),
                      // คุณสามารถก๊อปปี้ปุ่มมาวางเพิ่มตรงนี้ได้เลย มันจะเลื่อนขวาไปเรื่อยๆ ครับ
                      _buildMenuButton(Icons.settings, 'Settings', 'ตั้งค่าระบบ'), 
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // ---------------------------------------------------------
                // 4. ส่วน Reels (วิดีโอสั้น)
                // ---------------------------------------------------------
                Row(
                  children: const [
                    Text(
                      'Reels ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    Text(
                      '(วิดีโอสั้นให้ความรู้)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // เลื่อนแนวนอนได้
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildReelItem(),
                      _buildReelItem(),
                      _buildReelItem(),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // เผื่อระยะเว้นด้านล่างจอ
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget ย่อยสำหรับปุ่มเมนู ---
  Widget _buildMenuButton(IconData icon, String title, String subtitle) {
    return Container(
      width: 82, // ความกว้างแต่ละปุ่ม
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // เงาอ่อนๆ ให้ปุ่มดูลอยขึ้น
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Widget ย่อยสำหรับคลิป Reels ---
  Widget _buildReelItem() {
    return Container(
      width: 150,
      height: 240,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF), // สีเทาอ่อนๆ แทนวิดีโอ
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.black, // ปุ่ม Play สีดำ
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}