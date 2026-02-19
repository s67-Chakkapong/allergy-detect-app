import 'package:flutter/material.dart';

class GoodResultScreen extends StatelessWidget {
  const GoodResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5A3A);
    const bg = Color(0xFFEFEFEF);
    const cardRadius = 14.0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Good Result screen',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 10),

              // top image (placeholder)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_drink, size: 60, color: Colors.blue),
                      SizedBox(height: 6),
                      Text(
                        'MILK',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Cards
              _CardBox(
                title: 'ผลิตภัณฑ์สามารถรับประทานได้',
                titleColor: primaryGreen,
                radius: cardRadius,
                child: const Text(
                  'ผลิตภัณฑ์นี้ไม่มีส่วนผสมของ ...\nABCD ABCD',
                  style: TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
              ),

              const SizedBox(height: 14),

              _CardBox(
                title: 'ส่วนผสม',
                radius: cardRadius,
                child: const SizedBox(height: 120), // placeholder area
              ),

              const SizedBox(height: 14),

              _CardBox(
                title: 'โภชนาการ',
                radius: cardRadius,
                child: const SizedBox(height: 120), // placeholder area
              ),

              const Spacer(),

              // OK >>
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  child: const Text(
                    'OK  »',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final Widget child;
  final double radius;
  final Color? titleColor;

  const _CardBox({
    required this.title,
    required this.child,
    required this.radius,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
