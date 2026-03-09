import 'dart:convert';

enum LegalStatus { permitted, protected, seasonal }

class Species {
  final int id;
  final String commonNameEn;
  final String scientificName;
  final String label;
  final String? nameHindi;
  final String? nameCgLocal;
  final LegalStatus legalStatus;
  final int priceMinKg;
  final int priceMaxKg;
  final String? healthAdvisory;
  final List<int> seasonalBanMonths;

  const Species({
    required this.id,
    required this.commonNameEn,
    required this.scientificName,
    required this.label,
    this.nameHindi,
    this.nameCgLocal,
    required this.legalStatus,
    required this.priceMinKg,
    required this.priceMaxKg,
    this.healthAdvisory,
    required this.seasonalBanMonths,
  });

  factory Species.fromMap(Map<String, dynamic> map) {
    final commonName = map['common_name_en'] as String;
    return Species(
      id: map['id'] as int,
      commonNameEn: commonName,
      scientificName: map['scientific_name'] as String,
      label: (map['label'] as String?) ?? commonName.split('/').first.trim(),
      nameHindi: map['name_hindi'] as String?,
      nameCgLocal: map['name_cg_local'] as String?,
      legalStatus: LegalStatus.values.firstWhere(
        (e) => e.name == map['legal_status'],
        orElse: () => LegalStatus.permitted,
      ),
      priceMinKg: (map['price_min_kg'] as int?) ?? 0,
      priceMaxKg: (map['price_max_kg'] as int?) ?? 0,
      healthAdvisory: map['health_advisory'] as String?,
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
