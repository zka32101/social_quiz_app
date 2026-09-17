import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../repositories/profile_repository.dart' show activeProfileProvider;

/// AI コーチング ダッシュボード画面（Phase 4: shared_core 側 API 未整備のため準備中）
class AiCoachingDashboardScreen extends StatelessWidget {
  const AiCoachingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI コーチング'),
        backgroundColor: kSocialPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '近日公開予定です',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
