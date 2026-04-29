import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../data/mock_data.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _records = [];

  AttendanceProvider() {
    _loadMockData();
  }

  List<AttendanceRecord> get records => _records;

  AttendanceRecord? getTodayRecord() {
    final now = DateTime.now();
    try {
      return _records.firstWhere((r) => r.date.year == now.year && r.date.month == now.month && r.date.day == now.day);
    } catch (_) {
      return null;
    }
  }

  void _loadMockData() {
    _records = MockData.getAttendanceThisMonth();
    notifyListeners();
  }
}
