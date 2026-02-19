import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoodResultScreen extends StatelessWidget {
  const GoodResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFEFEF);
    const cardBg = Color(0xFFF6F3EF);
    const primaryGreen = Color(0xFF1F5A3A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ทำให้หน้าตาเหมือนมือถือแม้รันบนเว็บ/จอใหญ่
            final maxW = math.min(constraints.maxWidth, 360.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Top icon (MILK) ---
                        Center(
                          child: _MilkBadge(
                            // ถ้ามีรูปจริง ให้เปลี่ยนเป็น Image.asset ใน _MilkBadge ได้
                            label: 'MILK',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // --- Result card ---
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ผลิตภัณฑ์สามารถรับประทานได้',
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'ผลิตภัณฑ์นี้ไม่มีส่วนผสมของ ... ',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ABCD ABCD',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- Ingredients box ---
                        _SectionBox(
                          title: 'ส่วนผสม',
                          height: 140,
                        ),
                        const SizedBox(height: 10),

                        // --- Nutrition box ---
                        _SectionBox(
                          title: 'โภชนาการ',
                          height: 140,
                        ),
                        const SizedBox(height: 10),

                        // --- OK bottom-right ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black54,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              minimumSize: const Size(10, 10),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'OK »',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MilkBadge extends StatelessWidget {
  final String label;
  const _MilkBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_drink, size: 34, color: Color(0xFF1E88E5)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E88E5),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionBox extends StatelessWidget {
  final String title;
  final double height;
  const _SectionBox({required this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}
