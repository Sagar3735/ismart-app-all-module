import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LMSScreen extends StatelessWidget {
  const LMSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LMSScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('LMSScreen Content Coming Soon'),
      ),
    );
  }
}
