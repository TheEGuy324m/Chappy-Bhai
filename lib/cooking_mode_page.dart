import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cheffy/widgets/common_ui.dart';

class CookingModePage extends StatefulWidget {
  final List<String> steps;

  CookingModePage({this.steps = const ["Step 1: Example", "Step 2: Example"]});

  @override
  _CookingModePageState createState() => _CookingModePageState();
}

class _CookingModePageState extends State<CookingModePage>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;
  Timer? stepTimer;
  int remainingTime = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Fire animation
  late AnimationController _fireController;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();

    _fireController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _fireAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });

    _fireController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fireController.dispose();
    stepTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
        stepTimer?.cancel();
        remainingTime = parseTime(widget.steps[currentStep]);
        if (remainingTime > 0) startTimer();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recipe Completed! 🎉")),
      );
    }
  }

  int parseTime(String step) {
    final regex = RegExp(r'(\d+)\s*min');
    final match = regex.firstMatch(step);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  void startTimer() {
    stepTimer?.cancel();
    stepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Time's up for this step ⏰")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.yellow[100],

      /// ✅ COMMON DRAWER
      drawer: buildDrawer(context),

      body: Column(
        children: [
          /// ✅ HEADER
          buildHeader(
            context: context,
            scaffoldKey: _scaffoldKey,
            screenWidth: screenWidth,
          ),

          /// MAIN COOKING UI
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            widget.steps[currentStep],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    /// Timer
                    if (remainingTime > 0)
                      Text(
                        "Time left: $remainingTime sec",
                        style:
                            TextStyle(fontSize: 20, color: Colors.red),
                      ),

                    SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          child: Text(
                            currentStep < widget.steps.length - 1
                                ? "Next Step"
                                : "Finish",
                          ),
                        ),
                        if (parseTime(widget.steps[currentStep]) > 0)
                          ElevatedButton(
                            onPressed: () {
                              remainingTime =
                                  parseTime(widget.steps[currentStep]);
                              startTimer();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                            child: Text("Start Timer"),
                          ),
                      ],
                    ),

                    SizedBox(height: 80),
                  ],
                ),

                /// 🔥 Fire animation
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: FirePainter(_fireAnimation.value),
                    child: SizedBox(height: 80),
                  ),
                ),
              ],
            ),
          ),

          /// ✅ FOOTER
          buildFooter(),
        ],
      ),
    );
  }
}

/// 🔥 FIRE PAINTER
class FirePainter extends CustomPainter {
  final double height;

  FirePainter(this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.7);

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.25, size.height - height, size.width * 0.5, size.height);
    path.quadraticBezierTo(size.width * 0.75,
        size.height - height / 2, size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FirePainter oldDelegate) => true;
}