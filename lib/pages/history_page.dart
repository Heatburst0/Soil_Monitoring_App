import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled_app/services/firestore_service.dart';

import '../services/bluetooth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  String selectedRange = "1 Day";
  late TabController _tabController;
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Temp / Moisture
  }

  Stream<List<SensorReading>> _getReadings() {
    final now = DateTime.now();
    DateTime fromDate;

    switch (selectedRange) {
      case "1 Hour":
        fromDate = now.subtract(const Duration(hours: 1));
        break;
      case "1 Day":
        fromDate = now.subtract(const Duration(days: 1));
        break;
      case "1 Week":
      default:
        fromDate = now.subtract(const Duration(days: 7));
    }

    return firestoreService.getReadings(fromDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: StreamBuilder<List<SensorReading>>(
        stream: _getReadings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final readings = snapshot.data!;
          if (readings.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          // Format X-axis labels
          final labels = _generateLabels(readings);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabs(),
                const SizedBox(height: 10),
                _buildSectionTitle("Graph View"),
                _buildGraphs(readings, labels),
                const SizedBox(height: 10),
                _buildDropdown(),
                const SizedBox(height: 10),
                _buildSectionTitle("List View"),
                _buildReadingsList(readings),
              ],
            ),
          );
        },
      ),
    );
  }


  List<String> _generateLabels(List<SensorReading> readings) {
    return readings.map((r) {
      if (selectedRange == "1 Hour" || selectedRange == "1 Day") {
        return DateFormat("HH:mm").format(r.timestamp);
      } else {
        return DateFormat("dd MMM").format(r.timestamp);
      }
    }).toList();
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "Temperature"),
        Tab(text: "Moisture"),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGraphs(List<SensorReading> readings, List<String> labels) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildLineChart(
            readings.map((r) => r.temperature).toList(),
            labels,
            Colors.orange,
            "Temperature in °C",
          ),
          _buildLineChart(
            readings.map((r) => r.moisture).toList(),
            labels,
            Colors.blue,
            "Moisture %",
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Show readings of ",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedRange,
          items: ["1 Hour", "1 Day", "1 Week"]
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedRange = val!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReadingsList(List<SensorReading> readings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: readings.length,
      itemBuilder: (context, index) {
        final r = readings[index];
        return ListTile(
          leading: const Icon(Icons.thermostat),
          title: Text(
              "Temp: ${r.temperature.toStringAsFixed(1)} °C, Moisture: ${r.moisture.toStringAsFixed(1)}%"),
          subtitle:
          Text(DateFormat("dd MMM yyyy, HH:mm").format(r.timestamp)),
        );
      },
    );
  }

  Widget _buildLineChart(
      List<double> values, List<String> labels, Color color, String yLabel) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RotatedBox(
                quarterTurns: -1,
                child: Center(
                  child: Text(
                    yLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LineChart(
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
                          interval: (labels.length / 4).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Text(
                                labels[index],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: ((values.reduce((a, b) => a > b ? a : b) -
                              values.reduce((a, b) => a < b ? a : b)) /
                              5)
                              .clamp(1, double.infinity),
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Time",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
