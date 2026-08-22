// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_streak_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingStreakModelAdapter extends TypeAdapter<SavingStreakModel> {
  @override
  final int typeId = 2;

  @override
  SavingStreakModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingStreakModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      targetAmount: fields[5] as double,
      totalSaved: fields[6] as double,
      startDate: fields[7] as DateTime,
      lastSavedDate: fields[8] as DateTime?,
      pausedDate: fields[9] as DateTime?,
      statusIndex: fields[10] as int,
      streakDates: (fields[11] as List).cast<DateTime>(),
      completedDays: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SavingStreakModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.targetAmount)
      ..writeByte(6)
      ..write(obj.totalSaved)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.lastSavedDate)
      ..writeByte(9)
      ..write(obj.pausedDate)
      ..writeByte(10)
      ..write(obj.statusIndex)
      ..writeByte(11)
      ..write(obj.streakDates)
      ..writeByte(12)
      ..write(obj.completedDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingStreakModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
