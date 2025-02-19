import 'dart:convert';

class HourlyData {
  final int hour;
  final int pass;
  final int defect;
  final int rejected;
  final int rectified;
  final int total;

  HourlyData({
    required this.hour,
    required this.pass,
    required this.defect,
    required this.rejected,
    required this.rectified,
    required this.total,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      hour: json['Hrs'] ?? 0,
      pass: json['Pass'] ?? 0,
      defect: json['Defect'] ?? 0,
      rejected: json['Rejected'] ?? 0,
      rectified: json['Rectified'] ?? 0,
      total: json['Total'] ?? 0,
    );
  }
}

class GroupedData {
  final String styleNo;
  final String lineName;
  final String color;
  final Map<int, HourlyData> hours;

  GroupedData({
    required this.styleNo,
    required this.lineName,
    required this.color,
    required this.hours,
  });

  static Map<int, HourlyData> _initializeHourlyData() {
    return { for (var hour in List.generate(16, (index) => index + 1)) hour : HourlyData(
        hour: hour,
        pass: 0,
        defect: 0,
        rejected: 0,
        rectified: 0,
        total: 0,
      ) };
  }

  factory GroupedData.fromJson(List<Map<String, dynamic>> jsonList) {
    if (jsonList.isEmpty) {
      throw Exception("Empty data for group");
    }

    final first = jsonList.first;

    // Initialize hourly data (H1–H16)
    final hourlyData = _initializeHourlyData();

    // Populate hourly data from JSON
    for (var item in jsonList) {
      final hour = item['Hrs'];
      if (hour != null && hour >= 1 && hour <= 16) {
        hourlyData[hour] = HourlyData.fromJson(item);
      }
    }

    return GroupedData(
      styleNo: first['StyleNo'] ?? '',
      lineName: first['LineName'] ?? '',
      color: first['Color'] ?? '',
      hours: hourlyData,
    );
  }
}


Future<List<GroupedData>> transformApiData(String apiResponse) async {
  final List<dynamic> jsonData = jsonDecode(apiResponse);

  // Group data by StyleNo, LineName, and Color
  final grouped = <String, List<Map<String, dynamic>>>{};

  for (var item in jsonData) {
    final key = '${item["StyleNo"]}-${item["LineName"]}-${item["Color"]}';
    grouped.putIfAbsent(key, () => []).add(item);
  }

  return grouped.values
      .map((groupItems) => GroupedData.fromJson(groupItems))
      .toList();
}
