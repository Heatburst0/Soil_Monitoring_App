import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/bluetooth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  String selectedRange = "1 Week";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Temp / Moisture
  }

  Stream<List<SensorReading>> _getReadings() {
    final now = DateTime.now();
    DateTime fromDate;

    switch (selectedRange) {
      case "1 Month":
        fromDate = now.subtract(Duration(days: 30));
        break;
      case "1 Year":
        fromDate = now.subtract(Duration(days: 365));
        break;
      default:
        fromDate = now.subtract(Duration(days: 7));
    }

    return FirebaseFirestore.instance
        .collection("readings")
        .where("timestamp", isGreaterThan: fromDate)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return SensorReading(
        temperature: (data["temperature"] as num).toDouble(),
        moisture: (data["moisture"] as num).toDouble(),
        timestamp: (data["timestamp"] as Timestamp).toDate(),
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SensorReading>>(
              stream: _getReadings(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final readings = snapshot.data!;
                if (readings.isEmpty) {
                  return Center(child: Text("No data available"));
                }

                // Format X-axis labels: show only a few spaced-out ones
                List<String> labels = readings.map((r) {
                  return DateFormat("dd MMM").format(r.timestamp);
                }).toList();

                return Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: "Temperature"),
                        Tab(text: "Moisture"),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 250, // Half height
                      padding: EdgeInsets.all(16),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLineChart(
                            readings.map((r) => r.temperature).toList(),
                            labels,
                            Colors.orange,
                          ),
                          _buildLineChart(
                            readings.map((r) => r.moisture).toList(),
                            labels,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          DropdownButton<String>(
            value: selectedRange,
            items: ["1 Week", "1 Month", "1 Year"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedRange = val!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> values, List<String> labels, Color color) {
    return LineChart(
      LineChartData(
        minY: values.reduce((a, b) => a < b ? a : b) - 1,
        maxY: values.reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
                  (i) => FlSpot(i.toDouble(), values[i]),
            ),
            isCurved: true,
            color: color,
            dotData: FlDotData(show: false),
          )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (values.length / 4).ceilToDouble(), // Avoid clutter
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(
                    labels[index],
                    style: TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
      ),
    );
  }
}
