import 'package:hive/hive.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 1)
class AlternativeMatch extends HiveObject {
  @HiveField(0)
  late String label;

  @HiveField(1)
  late int speciesId;

  @HiveField(2)
  late double confidence;
}

@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String imagePath;

  @HiveField(2)
  late int speciesId;

  @HiveField(3)
  late String speciesLabel;

  @HiveField(4)
  late double confidence;

  @HiveField(5)
  late DateTime timestamp;

  @HiveField(6)
  late List<AlternativeMatch> alternatives;

  @HiveField(7)
  late bool isLowConfidence;

  @HiveField(8)
  late bool usedMockInference;
}
