import 'package:fl_chart/fl_chart.dart';
import 'package:ppms/Line/line2.dart';
import 'package:ppms/Resourse/indicator.dart';
import 'package:flutter/material.dart';

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  void navigateToLine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LineChartSample2(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: ()=> navigateToLine(context),
            child: const Text('Pie Chart Sample 2')),
      ),
      body: SafeArea(
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 18,
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(),
                    ),
                  ),
                ),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Indicator(
                    color: Colors.blue,
                    text: 'First',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Indicator(
                    color: Colors.yellow,
                    text: 'Second',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Indicator(
                    color: Colors.purple,
                    text: 'Third',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Indicator(
                    color: Colors.green,
                    text: 'Fourth',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 18,
                  ),
                ],
              ),
              const SizedBox(
                width: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 12.0;
      final radius = isTouched ? 50.0 : 30.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.purple,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.green,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
