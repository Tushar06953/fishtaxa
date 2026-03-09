import 'dart:convert';

enum LegalStatus { permitted, protected, seasonal }

class Species {
  final int id;
  final String commonNameEn;
  final String scientificName;
  final String label;
  final String? otherNames;
  final LegalStatus legalStatus;
  final int priceMinKg;
  final int priceMaxKg;
  final String? healthUses;
  final List<int> seasonalBanMonths;

  const Species({
    required this.id,
    required this.commonNameEn,
    required this.scientificName,
    required this.label,
    this.otherNames,
    required this.legalStatus,
    required this.priceMinKg,
    required this.priceMaxKg,
    this.healthUses,
    required this.seasonalBanMonths,
  });

  /// Returns other names as a list, split by pipe character.
  List<String> get otherNamesList {
    if (otherNames == null || otherNames!.trim().isEmpty) return [];
    return otherNames!.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  /// Returns health use points as a list, split by pipe character.
  List<String> get healthUsesList {
    if (healthUses == null || healthUses!.trim().isEmpty) return [];
    return healthUses!.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  factory Species.fromMap(Map<String, dynamic> map) {
    final commonName = map['common_name_en'] as String;
    return Species(
      id: map['id'] as int,
      commonNameEn: commonName,
      scientificName: map['scientific_name'] as String,
      label: (map['label'] as String?) ?? commonName.split('/').first.trim(),
      otherNames: map['other_names'] as String?,
      legalStatus: LegalStatus.values.firstWhere(
            (e) => e.name == map['legal_status'],
        orElse: () => LegalStatus.permitted,
      ),
      priceMinKg: (map['price_min_kg'] as int?) ?? 0,
      priceMaxKg: (map['price_max_kg'] as int?) ?? 0,
      healthUses: map['health_uses'] as String?,
      seasonalBanMonths: map['seasonal_ban_months'] != null
          ? List<int>.from(jsonDecode(map['seasonal_ban_months'] as String))
          : [],
    );
  }

  String get legalStatusDisplay {
    switch (legalStatus) {
      case LegalStatus.permitted:
        return 'Permitted';
      case LegalStatus.protected:
        return 'Protected';
      case LegalStatus.seasonal:
        return 'Seasonal';
    }
  }
}