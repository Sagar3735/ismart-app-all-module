import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VoiceMessagesScreen extends StatelessWidget {
  const VoiceMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VoiceMessagesScreen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('VoiceMessagesScreen Content Coming Soon'),
      ),
    );
  }
}
