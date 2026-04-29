import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ContactHRScreen extends StatelessWidget {
  const ContactHRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ContactHRScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('ContactHRScreen Content Coming Soon'),
      ),
    );
  }
}
