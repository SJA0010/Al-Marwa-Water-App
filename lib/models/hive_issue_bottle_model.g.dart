// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_issue_bottle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveBottleIssueAdapter extends TypeAdapter<HiveBottleIssue> {
  @override
  final int typeId = 6;

  @override
  HiveBottleIssue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveBottleIssue(
      customerId: fields[0] as int,
      quantity: fields[1] as String,
      buildingName: fields[2] as String,
      block: fields[3] as String,
      room: fields[4] as String,
      saleUserId: fields[5] as String,
      date: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveBottleIssue obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.buildingName)
      ..writeByte(3)
      ..write(obj.block)
      ..writeByte(4)
      ..write(obj.room)
      ..writeByte(5)
      ..write(obj.saleUserId)
      ..writeByte(6)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveBottleIssueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
