import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/scan_result.dart';
import '../../../shared/providers/history_provider.dart';
import '../../../shared/providers/species_db_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.ocean,
                    title: const Text('Clear History',
                        style: TextStyle(color: AppColors.textPrimary)),
                    content: const Text(
                        'Delete all scan history? This cannot be undone.',
                        style: TextStyle(color: AppColors.textMuted)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(scanHistoryProvider.notifier).clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All',
                            style: TextStyle(color: AppColors.coral)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.coral),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: history.length,
              itemBuilder: (context, i) => Dismissible(
                key: Key(history[i].id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(scanHistoryProvider.notifier).deleteAt(i);
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child:
                      const Icon(Icons.delete_outline, color: AppColors.coral),
                ),
                child: _HistoryTile(
                  result: history[i],
                  onTap: () => context.push(
                    '/scan/result',
                    extra: {'resultId': history[i].id},
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(milliseconds: i * 40), duration: 300.ms)
                    .slideX(
                      begin: -0.05,
                      end: 0,
                      delay: Duration(milliseconds: i * 40),
                      duration: 300.ms,
                    ),
              ),
            ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const _HistoryTile({required this.result, required this.onTap});

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
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
                width: 64,
                height: 64,
                child: File(result.imagePath).existsSync()
                    ? Image.file(
                        File(result.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  speciesAsync.when(
                    data: (s) => Text(
                      s?.commonNameEn ?? result.speciesLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () =>
                        Text(result.speciesLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                    error: (_, __) => Text(result.speciesLabel),
                  ),
                  const SizedBox(height: 2),
                  speciesAsync.when(
                    data: (s) => s != null
                        ? Text(
                            s.scientificName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(result.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _confidenceColor(result.confidence)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _confidenceColor(result.confidence)
                          .withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style:
                        Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: _confidenceColor(result.confidence),
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ),
                if (result.usedMockInference)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'demo',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.gold.withOpacity(0.7),
                              ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.deep,
      child: const Icon(Icons.set_meal,
          color: AppColors.textMuted, size: 28),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history,
            color: AppColors.textMuted,
            size: 72,
          ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No scans yet',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.textMuted),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Your scan history will appear here',
            style: Theme.of(context).textTheme.bodySmall,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
