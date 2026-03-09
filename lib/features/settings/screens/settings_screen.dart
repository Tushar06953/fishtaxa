import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/inference_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMock = InferenceService.isUsingMock;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Model status
          _SectionHeader('AI Model', context),
          _SettingCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isMock ? AppColors.gold : AppColors.permitted)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMock ? Icons.science_outlined : Icons.check_circle_outline,
                    color: isMock ? AppColors.gold : AppColors.permitted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMock ? 'Demo Mode' : 'AI Model Active',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isMock
                            ? 'Add fish_classifier_v1.tflite to enable AI'
                            : 'MobileNetV3-Small INT8 — real inference active',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),
          _SectionHeader('Database', context),
          _SettingCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage_outlined,
                      color: AppColors.tealBright, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Species Database',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '26 North Indian river species · SQLite · Offline',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle,
                    color: AppColors.permitted, size: 18),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

          const SizedBox(height: 20),
          _SectionHeader('Languages Supported', context),
          _SettingCard(
            child: Column(
              children: [
                langRow('English', 'EN', context),
                _divider(),
                langRow('हिन्दी', 'HI', context),
                _divider(),
                langRow('தமிழ்', 'TA', context),
                _divider(),
                langRow('বাংলা', 'BN', context),
              ],
            ),
          ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

          const SizedBox(height: 20),
          _SectionHeader('App Info', context),
          _SettingCard(
            child: Column(
              children: [
                infoRow('App Name', 'FishTaxa', context),
                _divider(),
                infoRow('Version', '1.0.0', context),
                _divider(),
                infoRow('Species Count', '26', context),
                _divider(),
                infoRow('Platform', 'Android (Offline)', context),
                _divider(),
                infoRow(
                    'Inference', isMock ? 'Demo Mode' : 'TFLite Active', context),
              ],
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

          const SizedBox(height: 20),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.offline_bolt,
                        color: AppColors.biolum, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Fully Offline',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'FishTaxa works completely without internet. All AI inference, species data, and history are stored on your device.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 320.ms, duration: 400.ms),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.cardBorder);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final BuildContext ctx;
  const _SectionHeader(this.title, this.ctx);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ocean,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

Widget langRow(String name, String code, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Text(name,
            style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.teal.withOpacity(0.4)),
          ),
          child: Text(
            code,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.tealBright,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    ),
  );
}

Widget infoRow(String label, String value, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted)),
        const Spacer(),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
