import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../data/mock_data.dart';

class EmployeeProvider extends ChangeNotifier {
  Employee? _employee;
  List<LeaveBalance> _leaveBalances = [];

  EmployeeProvider() {
    _loadMockData();
  }

  Employee? get employee => _employee;
  List<LeaveBalance> get leaveBalances => _leaveBalances;

  void _loadMockData() {
    _employee = MockData.currentEmployee;
    _leaveBalances = MockData.leaveBalances;
    notifyListeners();
  }
}
