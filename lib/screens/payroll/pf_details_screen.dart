import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PFDetailsScreen extends StatelessWidget {
  const PFDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PFDetailsScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('PFDetailsScreen Content Coming Soon'),
      ),
    );
  }
}
