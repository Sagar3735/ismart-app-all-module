import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RelieverScreen extends StatelessWidget {
  const RelieverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RelieverScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('RelieverScreen Content Coming Soon'),
      ),
    );
  }
}
