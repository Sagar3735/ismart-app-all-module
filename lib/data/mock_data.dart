import '../models/employee.dart';
import '../models/attendance.dart';
import '../models/leave.dart';

class MockData {
  static const currentEmployee = Employee(
    id: 'EMP-0123',
    name: 'Alex Johnson',
    designation: 'Senior Frontend Developer',
    department: 'Engineering',
    email: 'alex.j@company.com',
    phone: '+1 987 654 3210',
    bloodGroup: 'O+',
    dateOfJoining: '12 Jan 2021',
    workLocation: 'New York HQ',
    profilePhoto: 'https://i.pravatar.cc/150?img=11',
    shift: Shift(name: 'Standard', startTime: '09:00 AM', endTime: '06:00 PM'),
    reportingManagers: [
      ReportingManager(
        id: 'RM1',
        initials: 'PM',
        name: 'Priya Mehta',
        role: 'Direct Manager',
        department: 'IT Department',
        avatarColor: 0xFF2563EB,
      ),
      ReportingManager(
        id: 'RM2',
        initials: 'RK',
        name: 'Rajesh Kumar',
        role: 'Senior Manager',
        department: 'Operations',
        avatarColor: 0xFF6366F1,
      ),
      ReportingManager(
        id: 'RM3',
        initials: 'SP',
        name: 'Sneha Patil',
        role: 'HR Manager',
        department: 'People & Culture',
        avatarColor: 0xFF22C55E,
      ),
    ],
  );

  static const List<LeaveBalance> leaveBalances = [
    LeaveBalance(id: 'casual', label: 'Casual', icon: 'vacation', total: 12, used: 0, balance: 12, color: 0xFF2563EB),
    LeaveBalance(id: 'sick', label: 'Sick', icon: 'medical_services', total: 10, used: 4, balance: 6, color: 0xFFEF4444),
    LeaveBalance(id: 'earned', label: 'Earned', icon: 'star', total: 20, used: 2, balance: 18, color: 0xFF22C55E),
    LeaveBalance(id: 'compoff', label: 'Comp Off', icon: 'schedule', total: 5, used: 3, balance: 2, color: 0xFF6366F1),
  ];

  static List<AttendanceRecord> getAttendanceThisMonth() {
    final now = DateTime.now();
    final List<AttendanceRecord> records = [];
    for (int i = 1; i <= now.day; i++) {
      final date = DateTime(now.year, now.month, i);
      if (date.weekday == 6 || date.weekday == 7) {
        records.add(AttendanceRecord(date: date, status: 'Weekend'));
        continue;
      }
      if (i == 1) {
        records.add(AttendanceRecord(date: date, status: 'Holiday'));
        continue;
      }
      if (i == 5) {
        records.add(AttendanceRecord(date: date, status: 'Leave'));
        continue;
      }
      if (i == 12) {
        records.add(AttendanceRecord(date: date, inTime: '09:05 AM', outTime: '01:00 PM', status: 'Half Day', location: 'Office', workMode: 'On-site', productiveHours: '03:55', punchStatus: 'Missing Out Punch'));
        continue;
      }
      if (i == 15) {
        records.add(AttendanceRecord(date: date, status: 'Absent'));
        continue;
      }
      
      bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
      String? outTime = isToday ? null : '06:15 PM';

      records.add(AttendanceRecord(
        date: date,
        inTime: '08:50 AM',
        outTime: outTime,
        status: 'Present',
        location: 'Office',
        workMode: 'On-site',
        overtime: i % 3 == 0 ? '01:30 Hrs' : null,
        shiftTiming: '09:00 AM – 06:00 PM · Standard',
        punchStatus: isToday ? 'Punched In' : 'Punched Out',
        productiveHours: isToday ? '04:30' : '09:25',
      ));
    }
    return records;
  }

  static List<LeaveApplication> leaveHistory = [
    LeaveApplication(
      id: 'L1',
      type: 'Casual',
      fromDate: DateTime.now().subtract(const Duration(days: 10)),
      toDate: DateTime.now().subtract(const Duration(days: 9)),
      days: 2,
      reason: 'Personal work',
      managerId: 'RM1',
      status: 'Approved',
    ),
    LeaveApplication(
      id: 'L2',
      type: 'Sick',
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now().subtract(const Duration(days: 30)),
      days: 1,
      reason: 'Fever',
      managerId: 'RM2',
      status: 'Approved',
    ),
  ];
}
