import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:untitled_app/auth.dart';
import 'package:untitled_app/services/sensor_provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final User? user = Auth().currentUser;
    // final formattedDate = ;
    return Scaffold(
      appBar: AppBar(title: const Text("Soil Monitoring")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Latest Readings Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Latest Readings",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGauge("Temperature", provider.latestReading?.temperature ?? 0, Colors.yellow, "°C"),
                        _buildGauge("Moisture", provider.latestReading?.moisture ?? 0, Colors.blue, "%"),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (provider.latestReading != null)
                      Text(
                        "Last Collected On:  ${DateFormat("d MMM h:mm a").format(provider.latestReading!.timestamp)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Buttons
            if (provider.isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await provider.fetchReading();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Readings have been fetched")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 40),
                    ),
                    child: const Text("Test"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      if (provider.latestReading == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No readings available. Please test first.")),
                        );
                      } else {
                        provider.notifyListeners(); // refresh card
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(150, 40),
                    ),
                    child: const Text("Reports"),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text("Click on Test button to manually fetch latest readings"),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () async {
                await Auth().signOut();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signed out successfully")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 40),
              ),
              child: const Text("Sign out"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String label, double value, Color color, String unit) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 0,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: value,
                    color: color,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                ],
                pointers: const <GaugePointer>[], // no needle
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "${value.toStringAsFixed(1)} $unit",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.1,
                  ),
                ],
              )
            ],
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

}
