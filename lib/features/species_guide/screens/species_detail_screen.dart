import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/species.dart';
import '../../../shared/providers/species_db_provider.dart';

class SpeciesDetailScreen extends ConsumerWidget {
  final int speciesId;

  const SpeciesDetailScreen({super.key, required this.speciesId});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Color _statusColor(LegalStatus s) {
    switch (s) {
      case LegalStatus.permitted:
        return AppColors.permitted;
      case LegalStatus.protected:
        return AppColors.coral;
      case LegalStatus.seasonal:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(speciesByIdProvider(speciesId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: speciesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.tealBright),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.coral)),
        ),
        data: (species) {
          if (species == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('Species not found',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            );
          }
          return _buildContent(context, species);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Species species) {
    final statusColor = _statusColor(species.legalStatus);
    final category = AppConstants.speciesCategory[species.label];
    final catColor = category != null
        ? (AppConstants.categoryColor[category] ?? AppColors.tealBright)
        : AppColors.tealBright;
    final isInvasive = category == 'Invasive Species';

    return CustomScrollView(
      slivers: [
        // [A] HERO IMAGE
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.navy,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/species/${species.label}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/placeholder/fish.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.deep,
                      child: Center(
                        child: Icon(
                          Icons.set_meal,
                          color: AppColors.teal.withValues(alpha: 0.5),
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.navy.withValues(alpha: 0.85),
                        AppColors.navy,
                      ],
                      stops: const [0.4, 0.8, 1.0],
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
                // [B] SPECIES NAME BLOCK
                Text(
                  species.commonNameEn,
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  species.scientificName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                ).animate().fadeIn(delay: 60.ms, duration: 400.ms),
                const SizedBox(height: 14),

                // Category + Legal status chips
                Row(
                  children: [
                    if (category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: catColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '${isInvasive ? '⚠ ' : ''}$category',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: catColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            species.legalStatus == LegalStatus.permitted
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_outlined,
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            species.legalStatusDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // [C] PRICE CARD
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Market Price',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 12),

                // [D] REGIONAL NAMES CARD
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Regional Names',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.tealBright,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _nameRow('🇮🇳 Hindi', species.nameHindi, context),
                      const SizedBox(height: 10),
                      _nameRow('🇮🇳 CG / Local', species.nameCgLocal, context),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 12),

                // [E] HEALTH ADVISORY CARD
                if (species.healthAdvisory != null) ...[
                  _healthAdvisoryCard(
                      context, species.healthAdvisory!, isInvasive)
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                ],

                // [F] SEASONAL CALENDAR CARD
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: AppColors.tealBright, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Seasonal Calendar',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.tealBright),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _monthGrid(context, species.seasonalBanMonths),
                      if (species.seasonalBanMonths.isEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.permitted, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Open all year — no seasonal restrictions',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.permitted),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 60),
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

  Widget _healthAdvisoryCard(
      BuildContext context, String advisory, bool isInvasive) {
    final bullets = advisory
        .split('. ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return _SectionCard(
      child: Column(
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
                    color: isFirstInvasive
                        ? AppColors.coral
                        : AppColors.permitted,
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
      ),
    );
  }

  Widget _monthGrid(BuildContext context, List<int> bannedMonths) {
    Widget chip(int index) {
      final monthNum = index + 1;
      final isBanned = bannedMonths.contains(monthNum);
      return Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: isBanned
              ? AppColors.coral.withValues(alpha: 0.2)
              : AppColors.permitted.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBanned
                ? AppColors.coral.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            _months[index],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isBanned ? AppColors.coral : AppColors.textMuted,
                  fontWeight:
                      isBanned ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, chip),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => chip(i + 6)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

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
