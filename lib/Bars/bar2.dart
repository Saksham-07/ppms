import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppms/Line/line1.dart';
import 'package:ppms/Pie/pie1.dart';

class Bar2Page extends StatefulWidget {
  const Bar2Page({super.key});

  @override
  _Bar2PageState createState() => _Bar2PageState();
}

class _Bar2PageState extends State<Bar2Page> {
  late int showingTooltip;

  @override
  void initState() {
    showingTooltip = -1;
    super.initState();
  }

  BarChartGroupData generateGroupData(int x, int y) {
    final isTouched = showingTooltip == x;
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: isTouched ? Colors.orange : Colors.green, // Change colors as needed
        ),
      ],
    );
  }
  // void navigateToBar(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BarChartP(),
  //     ),
  //   );
  // }
  void navigateToPie(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PieChartSample2(),
      ),
    );
  }void navigateToLine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LineChartSample1(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GestureDetector(
        // onTap: ()=> navigateToBar(context),
          onLongPress: ()=> navigateToPie(context),
          onDoubleTap: ()=> navigateToLine(context),
          child: const Text("Bar2 Page"))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                barGroups: [
                  generateGroupData(1, 30),
                  generateGroupData(2, 24),
                  generateGroupData(3, 12),
                  generateGroupData(4, 19),
                  generateGroupData(5, 10),
                ],
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (response != null && response.spot != null && event is FlTapUpEvent) {
                      setState(() {
                        final x = response.spot!.touchedBarGroup.x;
                        final isShowing = showingTooltip == x;
                        if (isShowing) {
                          showingTooltip = -1;
                        } else {
                          showingTooltip = x;
                        }
                      });
                    }
                  },
                  mouseCursorResolver: (event, response) {
                    return response == null || response.spot == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
