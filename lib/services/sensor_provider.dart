import 'package:flutter/material.dart';
import 'bluetooth_service.dart';
import 'firestore_service.dart';

class SensorProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final firestoreService = FirestoreService();

  SensorReading? latestReading;
  final List<SensorReading> _history = [];
  bool isLoading = false;
  String? error;

  List<SensorReading> get history => List.unmodifiable(_history);

  Future<void> connectToDevice() async {
    try {
      final devices = await _bluetoothService.scanForDevices();
      await _bluetoothService.connect(devices.first);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchReading() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final reading = await _bluetoothService.getLatestReading();
      latestReading = reading;
      _history.add(reading);
      await firestoreService.saveReading(reading);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
