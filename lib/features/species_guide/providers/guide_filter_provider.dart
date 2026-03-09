import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/species.dart';
import '../../../shared/providers/species_db_provider.dart';

enum GuideFilter { all, majorCarp, catfish, snakehead, spinyEel, medicinal }

final guideFilterProvider =
    StateProvider<GuideFilter>((_) => GuideFilter.all);

final guideSearchProvider = StateProvider<String>((_) => '');

final filteredSpeciesProvider =
    Provider<AsyncValue<List<Species>>>((ref) {
  return ref.watch(allSpeciesProvider).whenData((all) {
    var list = all;
    final filter = ref.watch(guideFilterProvider);
    final q = ref.watch(guideSearchProvider).toLowerCase();

    if (filter == GuideFilter.majorCarp) {
      list = list.where((s) {
        final cat = AppConstants.speciesCategory[s.label];
        return cat == 'Major Carp';
      }).toList();
    } else if (filter == GuideFilter.catfish) {
      list = list.where((s) {
        final cat = AppConstants.speciesCategory[s.label];
        return cat == 'Prized Catfish' || cat == 'Premium Medicinal';
      }).toList();
    } else if (filter == GuideFilter.snakehead) {
      list = list.where((s) {
        final cat = AppConstants.speciesCategory[s.label];
        return cat == 'Snakehead';
      }).toList();
    } else if (filter == GuideFilter.spinyEel) {
      list = list.where((s) {
        final cat = AppConstants.speciesCategory[s.label];
        return cat == 'Spiny Eel';
      }).toList();
    } else if (filter == GuideFilter.medicinal) {
      list = list.where((s) {
        final cat = AppConstants.speciesCategory[s.label];
        return cat == 'Premium Medicinal';
      }).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((s) =>
        s.commonNameEn.toLowerCase().contains(q) ||
        s.scientificName.toLowerCase().contains(q) ||
        (s.nameHindi?.toLowerCase().contains(q) ?? false) ||
        (s.nameCgLocal?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return list;
  });
});
