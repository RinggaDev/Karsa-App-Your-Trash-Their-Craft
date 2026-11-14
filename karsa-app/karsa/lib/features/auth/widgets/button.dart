import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ButtonTestScreen(),
    );
  }
}

class ButtonTestScreen extends StatelessWidget {
  const ButtonTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Just to see the button clearly
      body: SafeArea(
        child: Center(
          // 1. Wrap in Padding so it has boundaries!
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Your Custom Button
                const CustomCtaButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCtaButton extends StatelessWidget {
  const CustomCtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Button Pressed!");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: InnerShadowPainter(
            blur: 3.7,
            offset: const Offset(0, 2),
            color: const Color(0xFFA4DE92).withOpacity(0.53),
            borderRadius: 12,
          ),
          child: Container(
            height: 64, 
            width: double.infinity, // This now takes the width of the Padding
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDDFFD3),
                  Color(0xFF63A156),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Mulai Berkontribusi!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28,
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

// The Inner Shadow Painter (unchanged)
class InnerShadowPainter extends CustomPainter {
  final double blur;
  final Offset offset;
  final Color color;
  final double borderRadius;

  InnerShadowPainter({
    required this.blur,
    required this.offset,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final Path innerPath = Path()..addRRect(rrect);

    canvas.save();
    canvas.clipPath(innerPath);

    final Path outerPath = Path()
      ..addRect(Rect.fromLTRB(
          -size.width, -size.height, size.width * 2, size.height * 2));

    final Path shadowPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);

    final Paint shadowPaint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(shadowPath, shadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter oldDelegate) {
    return oldDelegate.blur != blur ||
        oldDelegate.offset != offset ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}