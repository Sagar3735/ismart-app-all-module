class AttendanceRecord {
  final DateTime date;
  final String? inTime;
  final String? outTime;
  final String status; // Present, Absent, Half Day, Holiday, Weekend, Leave
  final String? location;
  final String? workMode;
  final String? overtime;
  final String? shiftTiming;
  final String? punchStatus;
  final String? productiveHours;

  const AttendanceRecord({
    required this.date,
    this.inTime,
    this.outTime,
    required this.status,
    this.location,
    this.workMode,
    this.overtime,
    this.shiftTiming,
    this.punchStatus,
    this.productiveHours,
  });

  String get totalHrs {
    if (inTime == null || outTime == null) return '—';
    try {
      // Very basic mock calculation
      return '09:00';
    } catch (_) {
      return '—';
    }
  }
}
