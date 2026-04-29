import 'package:flutter/material.dart';
import '../models/leave.dart';
import '../data/mock_data.dart';

class LeaveProvider extends ChangeNotifier {
  List<LeaveApplication> _leaveHistory = [];
  bool _isSubmitting = false;

  LeaveProvider() {
    _loadMockData();
  }

  List<LeaveApplication> get leaveHistory => _leaveHistory;
  bool get isSubmitting => _isSubmitting;

  void _loadMockData() {
    _leaveHistory = List.from(MockData.leaveHistory);
    notifyListeners();
  }

  Future<void> submitLeaveRequest(LeaveApplication application) async {
    _isSubmitting = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    _leaveHistory.insert(0, application);
    _isSubmitting = false;
    notifyListeners();
  }
}
