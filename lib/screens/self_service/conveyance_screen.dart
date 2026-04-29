import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ConveyanceScreen extends StatelessWidget {
  const ConveyanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ConveyanceScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('ConveyanceScreen Content Coming Soon'),
      ),
    );
  }
}
