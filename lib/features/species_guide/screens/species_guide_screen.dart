import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/guide_filter_provider.dart';
import '../widgets/species_card.dart';

class SpeciesGuideScreen extends ConsumerWidget {
  const SpeciesGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(guideFilterProvider);
    final searchQuery = ref.watch(guideSearchProvider);
    final filteredAsync = ref.watch(filteredSpeciesProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Species Guide'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) =>
              ref.read(guideSearchProvider.notifier).state = v,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, Hindi, local name...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () =>
                  ref.read(guideSearchProvider.notifier).state = '',
                  child: const Icon(Icons.close,
                      color: AppColors.textMuted, size: 20),
                )
                    : null,
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GuideFilter.values.map((filter) {
                  final selected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(filter)),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(guideFilterProvider.notifier)
                          .state = filter,
                      selectedColor: AppColors.teal,
                      checkmarkColor: Colors.white,
                      labelStyle:
                      Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.tealBright),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.coral)),
              ),
              data: (species) {
                if (species.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No species found',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: species.length,
                  itemBuilder: (context, i) => SpeciesCard(
                    species: species[i],
                  )
                      .animate()
                      .fadeIn(
                      delay: Duration(milliseconds: i * 30),
                      duration: 300.ms),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(GuideFilter f) {
    switch (f) {
      case GuideFilter.all:
        return 'All';
      case GuideFilter.majorCarp:
        return 'Major Carp';
      case GuideFilter.catfish:
        return 'Catfish';
      case GuideFilter.snakehead:
        return 'Snakehead';
      case GuideFilter.spinyEel:
        return 'Spiny Eel';
      case GuideFilter.medicinal:
        return 'Medicinal';
    }
  }
}