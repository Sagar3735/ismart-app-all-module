import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LeaveBalanceScreen extends StatelessWidget {
  const LeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LeaveBalanceScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('LeaveBalanceScreen Content Coming Soon'),
      ),
    );
  }
}
