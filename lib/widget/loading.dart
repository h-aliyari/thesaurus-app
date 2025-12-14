import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // تعداد دایره‌ها
  final int circles = 4;

  @override
  void initState() {
    super.initState();
    // کنترلر انیمیشن برای کل چرخه
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // طول یک چرخه کامل
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // تابع ایجاد دایره با
  Widget _buildCircle(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // فاصله زمانی شروع دایره‌ها: تقسیم چرخه به ۴ بخش
        double start = index / circles;

        // progress دایره (0..1) با offset
        double progress = (_controller.value + start) % 1.0;

        double scale = Tween<double>(begin: 0, end: 1).transform(progress);
        double opacity = Tween<double>(begin: 1, end: 0).transform(progress);

        return Transform.scale(
          scale: scale, // بزرگ شدن از مرکز
          child: Opacity(
            opacity: opacity, // محو شدن هنگام بزرگ شدن
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 52, 129, 55),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // پس‌زمینه سفید با شفافیت
      backgroundColor: Colors.white.withOpacity(0.8),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(circles, (index) {
            return _buildCircle(index);
          }),
        ),
      ),
    );
  }
}
