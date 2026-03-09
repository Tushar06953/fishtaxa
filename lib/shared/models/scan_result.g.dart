// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlternativeMatchAdapter extends TypeAdapter<AlternativeMatch> {
  @override
  final int typeId = 1;

  @override
  AlternativeMatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlternativeMatch()
      ..label = fields[0] as String
      ..speciesId = fields[1] as int
      ..confidence = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, AlternativeMatch obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.speciesId)
      ..writeByte(2)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlternativeMatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 0;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResult()
      ..id = fields[0] as String
      ..imagePath = fields[1] as String
      ..speciesId = fields[2] as int
      ..speciesLabel = fields[3] as String
      ..confidence = fields[4] as double
      ..timestamp = fields[5] as DateTime
      ..alternatives = (fields[6] as List).cast<AlternativeMatch>()
      ..isLowConfidence = fields[7] as bool
      ..usedMockInference = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.speciesId)
      ..writeByte(3)
      ..write(obj.speciesLabel)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.alternatives)
      ..writeByte(7)
      ..write(obj.isLowConfidence)
      ..writeByte(8)
      ..write(obj.usedMockInference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
