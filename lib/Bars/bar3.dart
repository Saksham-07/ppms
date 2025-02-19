import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample3 extends StatefulWidget {
  final List<Map<String, dynamic>> barData;
  final double minWidth;
  final maxY; // Minimum width for the bar chart


  const BarChartSample3({
    super.key,
    required this.barData,
    this.minWidth = 300.0,
    this.maxY,
  });

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  int? selectedGroupIndex;
  int? selectedRodIndex;

  @override
  Widget build(BuildContext context) {
    double calculatedWidth = widget.barData.length * 60.0;
    double finalWidth = calculatedWidth < widget.minWidth ? widget.minWidth : calculatedWidth;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: SizedBox(
                  width: finalWidth,
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: BarChart(
                      BarChartData(
                        backgroundColor: Colors.grey[200],
                        barGroups: widget.barData.map((data) {
                          return BarChartGroupData(
                            x: data['index'],
                            barRods: [
                              BarChartRodData(
                                toY: data['turnoverBar'].toDouble(),
                                gradient: const LinearGradient(
                                  colors: [Colors.cyan, Colors.greenAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 15,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 0,
                                  color: Colors.grey[300],
                                ),
                              ),
                              BarChartRodData(
                                toY: data['qtyBar'].toDouble(),
                                gradient: const LinearGradient(
                                  colors: [Colors.redAccent, Colors.orangeAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 15,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 0,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                            showingTooltipIndicators: selectedGroupIndex == data['index'] &&
                                selectedRodIndex != null
                                ? [selectedRodIndex!]
                                : [],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final label = widget.barData.firstWhere(
                                        (element) => element['index'] == value.toInt())['label'];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 5,
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.lightBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: const FlGridData(show: false),
                        groupsSpace: 20.0,
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: widget.maxY,
                        barTouchData: BarTouchData(
                          touchCallback: (event, response) {
                            if (response != null && response.spot != null) {
                              setState(() {
                                if (selectedGroupIndex ==
                                    response.spot!.touchedBarGroupIndex &&
                                    selectedRodIndex ==
                                        response.spot!.touchedRodDataIndex) {
                                  selectedGroupIndex = null;
                                  selectedRodIndex = null;
                                } else {
                                  selectedGroupIndex =
                                      response.spot!.touchedBarGroupIndex;
                                  selectedRodIndex =
                                      response.spot!.touchedRodDataIndex;
                                }
                              });
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (groupIndex == selectedGroupIndex &&
                                  rodIndex == selectedRodIndex) {
                                final data = widget.barData[groupIndex];
                                String tooltipText = rodIndex == 0
                                    ? data['turnoverValue'].toString()
                                    : data['qty'].toString();
                                return BarTooltipItem(
                                  tooltipText,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.cyan, 'Val'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.redAccent, 'Qty'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
