import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/species.dart';

class SpeciesCard extends StatelessWidget {
  final Species species;

  const SpeciesCard({super.key, required this.species});

  Color _statusColor() {
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
    final category = AppConstants.speciesCategory[species.label];
    final catColor = category != null
        ? (AppConstants.categoryColor[category] ?? AppColors.tealBright)
        : AppColors.tealBright;
    final isInvasive = category == 'Invasive Species';

    return GestureDetector(
      onTap: () => context.push('/guide/${species.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ocean,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.deep,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Icon(
                    Icons.set_meal,
                    color: AppColors.teal.withValues(alpha: 0.6),
                    size: 48,
                  ),
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonNameEn,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.scientificName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: catColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '${isInvasive ? '⚠ ' : ''}${category ?? 'Unknown'}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: catColor,
                                  fontSize: 9,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
