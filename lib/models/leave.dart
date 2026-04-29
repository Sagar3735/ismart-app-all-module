class LeaveApplication {
  final String id;
  final String type; // Casual, Sick, Earned, Comp Off
  final DateTime fromDate;
  final DateTime toDate;
  final double days;
  final String reason;
  final String managerId;
  final String status; // Approved, Pending, Rejected

  const LeaveApplication({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.managerId,
    required this.status,
  });
}
