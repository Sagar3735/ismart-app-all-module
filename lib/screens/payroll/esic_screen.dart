import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ESICScreen extends StatelessWidget {
  const ESICScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ESICScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('ESICScreen Content Coming Soon'),
      ),
    );
  }
}
