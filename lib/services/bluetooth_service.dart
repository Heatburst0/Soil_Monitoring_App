import 'dart:async';
import 'dart:math';

/// Represents a Bluetooth device (mocked).
class BluetoothDeviceMock {
  final String name;
  final String id;

  BluetoothDeviceMock({required this.name, required this.id});
}

/// Represents a reading from the soil sensor.
class SensorReading {
  final double temperature;
  final double moisture;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.moisture,
    required this.timestamp,
  });
}

/// Service to handle Bluetooth communication (mock for now).
class BluetoothService {
  final Random _random = Random();
  bool _connected = false;
  BluetoothDeviceMock? _device;

  /// Pretend to scan for devices
  Future<List<BluetoothDeviceMock>> scanForDevices() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate scanning
    return [
      BluetoothDeviceMock(name: "SoilSensor-01", id: "AA:BB:CC:DD:EE:FF"),
    ];
  }

  /// Pretend to connect to a device
  Future<void> connect(BluetoothDeviceMock device) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate connection delay
    _connected = true;
    _device = device;
  }

  /// Get the latest sensor reading (mocked values)
  Future<SensorReading> getLatestReading() async {
    if (!_connected) {
      throw Exception("No device connected");
    }

    await Future.delayed(const Duration(seconds: 1)); // simulate read delay

    return SensorReading(
      temperature: 20 + _random.nextInt(10) + _random.nextDouble(),
      moisture: 40 + _random.nextInt(30) + _random.nextDouble(),
      timestamp: DateTime.now(),
    );
  }

  bool get isConnected => _connected;
  BluetoothDeviceMock? get connectedDevice => _device;
}
