import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/history_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/offline_badge.dart';
import '../widgets/recent_scan_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && context.mounted) {
      context.push(
        '/scan/processing',
        extra: {'imagePath': xFile.path},
      );
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 11) return 'Good Morning 👋';
    if (hour >= 12 && hour <= 16) return 'Good Afternoon 👋';
    if (hour >= 17 && hour <= 20) return 'Good Evening 👋';
    return 'Good Night 👋';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(scanHistoryProvider);
    final recentScans = history.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Text(
          'FishTaxa',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: OfflineBadge()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.ocean,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to identify your catch?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.permitted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Running Offline AI',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.permitted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            ActionCard(
              label: '📷  Scan Fish',
              icon: Icons.camera_alt_outlined,
              isPrimary: true,
              onTap: () => context.push('/scan'),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 150.ms,
                  duration: 400.ms,
                ),
            const SizedBox(height: 12),
            ActionCard(
              label: '🖼  Choose from Gallery',
              icon: Icons.photo_library_outlined,
              onTap: () => _pickFromGallery(context),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 200.ms,
                  duration: 400.ms,
                ),
            const SizedBox(height: 36),
            Row(
              children: [
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: Text(
                      'See All',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.tealBright,
                              ),
                    ),
                  ),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            const SizedBox(height: 12),
            if (recentScans.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.ocean,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.set_meal_outlined,
                      color: AppColors.textMuted,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No scans yet',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan a fish to get started',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms)
            else
              ...recentScans.asMap().entries.map(
                    (e) => RecentScanTile(result: e.value)
                        .animate()
                        .fadeIn(
                            delay: Duration(milliseconds: 300 + e.key * 80),
                            duration: 400.ms)
                        .slideX(
                          begin: -0.1,
                          end: 0,
                          delay: Duration(
                              milliseconds: 300 + e.key * 80),
                          duration: 400.ms,
                        ),
                  ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
