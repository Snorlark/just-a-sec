// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryModelAdapter extends TypeAdapter<StoryModel> {
  @override
  final int typeId = 1;

  @override
  StoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryModel(
      title: fields[0] as String,
      content: fields[1] as String,
      storyVideoPath: fields[2] as String?,
      storyVideoDate: fields[4] as DateTime?,
      storyVideoTime: fields[3] as DateTime?,
      storyVideoLocation: fields[5] as String,
      storyVideoFilter: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.storyVideoPath)
      ..writeByte(3)
      ..write(obj.storyVideoTime)
      ..writeByte(4)
      ..write(obj.storyVideoDate)
      ..writeByte(5)
      ..write(obj.storyVideoLocation)
      ..writeByte(6)
      ..write(obj.storyVideoFilter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
