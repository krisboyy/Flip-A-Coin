import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CoinFlip());
}

class CoinFlip extends StatelessWidget {
  const CoinFlip({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Coin Flip',
      home: HomePage(title: 'Coin Flip Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final thicknessController = TextEditingController();
  final radiusController = TextEditingController();
  late AnimationController _animationController;
  double radius = 0;
  double thickness = 0;
  double volume = 0;
  double pi = 3.14;

  @override
  void initState() {
    super.initState();
    thicknessController.addListener(_thicknessListener);
    radiusController.addListener(_radiusListener);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _calculateVolume() {
    setState(() {
      volume = (pi * radius * radius * thickness);
    });
  }

  void _thicknessListener() {
    final text = thicknessController.text;
    double thickness = double.parse(text);
    this.thickness = thickness;
    _calculateVolume();
  }

  void _radiusListener() {
    final text = radiusController.text;
    double radius = double.parse(text);
    this.radius = radius;
    _calculateVolume();
  }

  Widget coinWidget() {
    return Container(
      decoration: BoxDecoration(),
    );
  }

  Widget formWidget(
    double widthPercentage,
    String label,
    BuildContext context,
    TextEditingController controller,
  ) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.015 * size.height),
      child: Column(
        children: [
          Text(label),
          Container(
            width: widthPercentage * size.width,
            child: TextField(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    radiusController.dispose();
    thicknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            formWidget(0.25, "Enter coin radius (in mm)", context, radiusController),
            formWidget(0.25, "Enter coin thickness (in mm)", context, thicknessController),
            Text("Volume of coin is ${volume} cub. mm."),
            Expanded(
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CoinPainter(angle: _animationController.value * 2 * pi, radius: radius, thickness: thickness),
                      child: Container(),
                    );
                  }),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CoinPainter extends CustomPainter {
  final double angle;
  final double radius;
  final double thickness;

  CoinPainter({required this.angle, required this.radius, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint frontPaint = Paint()..color = Colors.amber;
    final Paint backPaint = Paint()..color = Colors.grey;
    final Paint edgePaint = Paint()..color = Colors.brown;

    double scale = cos(angle).abs(); // 0 to 1, simulates the "depth"
    bool isFrontVisible = cos(angle) > 0; // Determine if the front or back is showing

    // Draw the edge of the coin with an arc
    if (scale > 0.01) {
      // Only draw if the edge is visible
      Rect edgeRect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: thickness * scale,
      );
      canvas.drawOval(edgeRect, edgePaint);
    }

    // Draw the front or back of the coin
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, 1); // Simulate 3D scaling for depth
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, radius, isFrontVisible ? frontPaint : backPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
