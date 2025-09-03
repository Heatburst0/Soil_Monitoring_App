import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/services/sensor_provider.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();

    if (provider.latestReading == null) {
      return const Scaffold(
        body: Center(child: Text("No readings available")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: ListView.builder(
        itemCount: provider.history.length,
        itemBuilder: (context, index) {
          final reading = provider.history[index];
          return ListTile(
            title: Text(
              "Temp: ${reading.temperature.toStringAsFixed(2)} °C | Moisture: ${reading.moisture.toStringAsFixed(2)} %",
            ),
            subtitle: Text("Time: ${reading.timestamp}"),
          );
        },
      ),
    );
  }
}
