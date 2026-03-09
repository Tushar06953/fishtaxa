import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/scan_result.dart';
import '../../../shared/models/species.dart';
import '../../../shared/providers/species_db_provider.dart';

class ResultScreen extends ConsumerWidget {
  final String resultId;

  const ResultScreen({super.key, required this.resultId});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  ScanResult? _findResult() {
    try {
      final box = Hive.box<ScanResult>('scan_history');
      for (final r in box.values) {
        if (r.id == resultId) return r;
      }
    } catch (_) {}
    return null;
  }

  Color _confidenceColor(double c) {
    if (c >= 0.8) return AppColors.permitted;
    if (c >= 0.6) return AppColors.gold;
    return AppColors.coral;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = _findResult();

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        appBar: AppBar(title: const Text('Result')),
        body: const Center(
          child: Text('Result not found',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    final speciesAsync = ref.watch(speciesByIdProvider(result.speciesId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: speciesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.tealBright),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (species) => _buildContent(context, result, species),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ScanResult result, Species? species) {
    final category = species != null
        ? AppConstants.speciesCategory[species.label]
        : null;
    final catColor = category != null
        ? (AppConstants.categoryColor[category] ?? AppColors.tealBright)
        : AppColors.tealBright;
    final isInvasive = category == 'Invasive Species';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.navy,
          leading: GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (File(result.imagePath).existsSync())
                  Image.file(
                    File(result.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                else
                  _placeholderImage(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.navy.withValues(alpha: 0.8),
                        AppColors.navy,
                      ],
                      stops: const [0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Low confidence banner
                if (result.isLowConfidence)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.coral.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            color: AppColors.coral, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Low confidence — result may not be accurate',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.coral),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                // Species name + confidence
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            species?.label ?? result.speciesLabel,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          if (species != null)
                            Text(
                              species.scientificName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _confidenceColor(result.confidence)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _confidenceColor(result.confidence)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        '${(result.confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: _confidenceColor(result.confidence),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 20),

                if (species != null) ...[
                  // Status + Category chips
                  Row(
                    children: [
                      _StatusChip(species: species),
                      if (category != null) ...[
                        const SizedBox(width: 10),
                        _CategoryChip(
                          category: category,
                          catColor: catColor,
                          isInvasive: isInvasive,
                        ),
                      ],
                    ],
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                  const SizedBox(height: 16),

                  // Price card
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Market Price',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Icon(Icons.currency_rupee,
                                color: AppColors.gold, size: 22),
                            Text(
                              '${species.priceMinKg} – ${species.priceMaxKg} per kg',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prices approximate. Vary by season and local market.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 12),

                  // Regional names
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Regional Names',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.tealBright),
                        ),
                        const SizedBox(height: 12),
                        if (species.otherNamesList.isNotEmpty)
                          _nameRow('🇮🇳 Local Names',
                              species.otherNamesList.join(' · '), context)
                        else
                          _nameRow('🇮🇳 Local Names', null, context),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                  const SizedBox(height: 12),

                  // Health advisory as bullets
                  if (species.healthUses != null)
                    _InfoCard(
                      child: _HealthAdvisoryContent(
                        advisory: species.healthUses!,
                        isInvasive: isInvasive,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  // Seasonal ban months
                  if (species.seasonalBanMonths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined,
                                  color: AppColors.gold, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Seasonal Ban',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(12, (i) {
                              final month = i + 1;
                              final isBanned = species.seasonalBanMonths
                                  .contains(month);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isBanned
                                      ? AppColors.gold.withValues(alpha: 0.2)
                                      : AppColors.cardBorder
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isBanned
                                        ? AppColors.gold.withValues(alpha: 0.6)
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  _months[i],
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isBanned
                                            ? AppColors.gold
                                            : AppColors.textMuted,
                                        fontWeight: isBanned
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                  ],

                  // Alternatives
                  if (result.alternatives.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Other Possibilities',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    ...result.alternatives
                        .take(2)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => _AlternativeRow(match: e.value)
                              .animate()
                              .fadeIn(
                                  delay: Duration(
                                      milliseconds: 450 + e.key * 60),
                                  duration: 400.ms),
                        ),
                  ],
                ],

                const SizedBox(height: 40),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/scan'),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Scan Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.go('/guide/${result.speciesId}'),
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: const Text('Species Info'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nameRow(String label, String? value, BuildContext context) {
    final isEmpty = value == null || value.trim().isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            isEmpty ? 'Not recorded in this region' : value,
            style: isEmpty
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.ocean,
      child: const Center(
        child: Icon(Icons.set_meal, color: AppColors.textMuted, size: 80),
      ),
    );
  }
}

class _HealthAdvisoryContent extends StatelessWidget {
  final String advisory;
  final bool isInvasive;
  const _HealthAdvisoryContent(
      {required this.advisory, required this.isInvasive});

  @override
  Widget build(BuildContext context) {
    final bullets = advisory
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.health_and_safety_outlined,
                color: AppColors.tealBright, size: 18),
            const SizedBox(width: 8),
            Text(
              'Health Advisory',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.tealBright),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...bullets.asMap().entries.map((entry) {
          final i = entry.key;
          final point = entry.value;
          final isFirstInvasive = isInvasive && i == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isFirstInvasive
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle,
                  color:
                      isFirstInvasive ? AppColors.coral : AppColors.permitted,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isFirstInvasive
                              ? AppColors.coral
                              : AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

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

class _StatusChip extends StatelessWidget {
  final Species species;
  const _StatusChip({required this.species});

  Color _color() {
    switch (species.legalStatus) {
      case LegalStatus.permitted:
        return AppColors.permitted;
      case LegalStatus.protected:
        return AppColors.coral;
      case LegalStatus.seasonal:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color().withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            species.legalStatus == LegalStatus.permitted
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: _color(),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            species.legalStatusDisplay,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _color(),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final Color catColor;
  final bool isInvasive;
  const _CategoryChip({
    required this.category,
    required this.catColor,
    required this.isInvasive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${isInvasive ? '⚠ ' : ''}$category',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: catColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _AlternativeRow extends StatelessWidget {
  final AlternativeMatch match;

  const _AlternativeRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ocean,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.label
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) =>
                      w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
                  .join(' '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(match.confidence * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: match.confidence,
                    backgroundColor: AppColors.cardBorder,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.teal),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
