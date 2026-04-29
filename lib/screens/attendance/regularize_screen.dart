import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RegularizeScreen extends StatelessWidget {
  const RegularizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RegularizeScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('RegularizeScreen Content Coming Soon'),
      ),
    );
  }
}
