import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/scan_result.dart';
import '../../../shared/providers/species_db_provider.dart';

class RecentScanTile extends ConsumerWidget {
  final ScanResult result;

  const RecentScanTile({super.key, required this.result});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _confidenceColor(double c) {
    if (c >= 0.8) return AppColors.permitted;
    if (c >= 0.6) return AppColors.gold;
    return AppColors.coral;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(speciesByIdProvider(result.speciesId));

    return GestureDetector(
      onTap: () => context.push('/scan/result', extra: {'resultId': result.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ocean,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: File(result.imagePath).existsSync()
                    ? Image.file(
                        File(result.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  speciesAsync.when(
                    data: (species) => Text(
                      species?.commonNameEn ?? result.speciesLabel,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => Text(
                      result.speciesLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    error: (_, __) => Text(result.speciesLabel),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(result.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _confidenceColor(result.confidence).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _confidenceColor(result.confidence).withOpacity(0.5),
                ),
              ),
              child: Text(
                '${(result.confidence * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _confidenceColor(result.confidence),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.ocean,
      child: const Icon(Icons.set_meal, color: AppColors.textMuted, size: 28),
    );
  }
}
