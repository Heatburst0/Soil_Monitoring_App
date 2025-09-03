import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/bluetooth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveReading(SensorReading reading) async {
    await _db.collection("readings").add({
      "temperature": reading.temperature,
      "moisture": reading.moisture,
      "timestamp": reading.timestamp,
    });
    print("✅ Successfully saved reading!");
  }

  /// Get all readings (latest first)
  Stream<List<SensorReading>> getReadings() {
    return _db
        .collection("readings")
        .orderBy("timestamp", descending: true)
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
}
