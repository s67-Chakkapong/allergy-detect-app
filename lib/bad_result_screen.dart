import 'package:flutter/material.dart';

class BadResultScreen extends StatelessWidget {
  const BadResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFEFEF);
    const cardBg = Colors.white;

    const danger = Color(0xFFD32F2F); // แดงหัวข้อ
    const dangerSoft = Color(0x33D32F2F); // เงา/กรอบแดงอ่อน
    const titleGreen = Color(0xFF1F5A3A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // top label
                  const Padding(
                    padding: EdgeInsets.only(left: 6, bottom: 10),
                  ),

                  // icon milk (placeholder)
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3EF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.local_drink, size: 34, color: Colors.blue),
                          SizedBox(height: 6),
                          Text(
                            'MILK',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // card 1 (red warning)
                  _InfoCard(
                    title: 'ผลิตภัณฑ์นี้ไม่สามารถรับประทานได้',
                    titleColor: danger,
                    shadowColor: dangerSoft,
                    body: 'ผลิตภัณฑ์นี้มีส่วนผสมของ ... อาจก่อให้เกิดอาการแพ้ '
                        'ควรหลีกเลี่ยง',
                    body2: '',
                    bg: cardBg,
                  ),

                  const SizedBox(height: 14),

                  // card 2 ingredients
                  _BigBoxCard(
                    title: 'ส่วนผสม',
                    titleColor: danger,
                    shadowColor: dangerSoft,
                    height: 170,
                    bg: cardBg,
                    child: const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 14),

                  // card 3 nutrition
                  _BigBoxCard(
                    title: 'โภชนาการ',
                    titleColor: danger,
                    shadowColor: dangerSoft,
                    height: 170,
                    bg: cardBg,
                    child: const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 16),

                  // bottom right OK >>
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text(
                        'OK »',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color shadowColor;
  final String body;
  final String body2;
  final Color bg;

  const _InfoCard({
    required this.title,
    required this.titleColor,
    required this.shadowColor,
    required this.body,
    required this.body2,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.black54, height: 1.25)),
          if (body2.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(body2, style: const TextStyle(color: Colors.black54, height: 1.25)),
          ],
        ],
      ),
    );
  }
}

class _BigBoxCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color shadowColor;
  final double height;
  final Widget child;
  final Color bg;

  const _BigBoxCard({
    required this.title,
    required this.titleColor,
    required this.shadowColor,
    required this.height,
    required this.child,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 7)),
        ],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
