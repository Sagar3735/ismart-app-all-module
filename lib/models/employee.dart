class Employee {
  final String id, name, designation, department;
  final String email, phone, bloodGroup, dateOfJoining, workLocation;
  final String profilePhoto;
  final Shift shift;
  final List<ReportingManager> reportingManagers;

  const Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.dateOfJoining,
    required this.workLocation,
    required this.profilePhoto,
    required this.shift,
    required this.reportingManagers,
  });
}

class Shift {
  final String name, startTime, endTime;
  const Shift({
    required this.name,
    required this.startTime,
    required this.endTime,
  });
}

class ReportingManager {
  final String id, initials, name, role, department;
  final int avatarColor; // Color value as int e.g. 0xFF6366F1
  const ReportingManager({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.department,
    required this.avatarColor,
  });
}

class LeaveBalance {
  final String id, label, icon;
  final int total, used, balance;
  final int color;
  const LeaveBalance({
    required this.id,
    required this.label,
    required this.icon,
    required this.total,
    required this.used,
    required this.balance,
    required this.color,
  });
}
