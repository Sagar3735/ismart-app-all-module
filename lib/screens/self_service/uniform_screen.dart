import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class UniformScreen extends StatelessWidget {
  const UniformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('UniformScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('UniformScreen Content Coming Soon'),
      ),
    );
  }
}
