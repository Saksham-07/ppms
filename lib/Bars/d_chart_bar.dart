import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:d_chart/d_chart.dart';

class DChartBar extends StatefulWidget {
  final List<OrdinalGroup> dataGroups;
  final double barWidth;

  final String unit;

  const DChartBar({super.key, required this.dataGroups, required this.barWidth, required this.unit});

  @override
  DChartBarState createState() => DChartBarState();
}

class DChartBarState extends State<DChartBar> {
  late String turnoverUnit;

  @override
  void initState() {
    super.initState();
    determineTurnoverUnit();
  }

  String formatTurnoverValue(double value) {
    if (value >= 1) {
      return (value / 10000000).toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(0);
    }
  }

  void determineTurnoverUnit() {
    num maxTurnover = 0;
    for (var group in widget.dataGroups) {
      for (var data in group.data) {
        if (data.measure > maxTurnover) {
          maxTurnover = data.measure;
          print(maxTurnover);
          print('dchsjdchkjsdcksnncksndkjcbnn');
        }
      }
    }
      turnoverUnit = maxTurnover >= 10000000 ? "Crores" : "Lakhs";
  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widget.dataGroups.map((group) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: group.color,
              ),
              const SizedBox(width: 4),
              Text(
                group.id,
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buyer',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text('in $turnoverUnit', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    buildLegend(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width + widget.barWidth,
                    height: 300.0,
                    child: DChartBarO(
                      vertical: true,
                      animate: true,
                      animationDuration: const Duration(milliseconds: 900),
                      layoutMargin: LayoutMargin(10, 10, 8, 80),
                      configRenderBar: ConfigRenderBar(
                        showBarLabel: true,
                        maxBarWidthPx: 60,
                        barLabelDecorator: BarLabelDecorator(
                          barLabelPosition: BarLabelPosition.auto,
                          labelAnchor: BarLabelAnchor.end,
                          outsideLabelStyle: const LabelStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                          insideLabelStyle: const LabelStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      domainAxis: DomainAxis(
                        showLine: true,
                        lineStyle: LineStyle(
                            color: Colors.grey.shade200
                        ),
                        tickLength: 8,
                        labelRotation: 45,
                        gapAxisToLabel: 8,
                        labelStyle: const LabelStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                      measureAxis: MeasureAxis(
                        gapAxisToLabel: 4,
                        showLine: false,
                        noRenderSpec: true,
                        numericTickProvider: const NumericTickProvider(
                          desiredMinTickCount: 5,
                          desiredMaxTickCount: 7,
                        ),
                        gridLineStyle: LineStyle(
                          color: Colors.grey.shade300,
                          dashPattern: [4],
                        ),
                        labelStyle: const LabelStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                      barLabelValue: (group, data, index) {
                        return formatTurnoverValue(data.measure.toDouble());
                      },
                      groupList: widget.dataGroups,
                    ),
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

