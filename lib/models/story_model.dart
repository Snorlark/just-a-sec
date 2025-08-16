import 'package:hive/hive.dart';

part 'story_model.g.dart';

@HiveType(typeId: 1)
class StoryModel extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String content;

  @HiveField(2)
  String? storyVideoPath;

  @HiveField(3)
  DateTime? storyVideoTime;

  @HiveField(4)
  DateTime? storyVideoDate;

  @HiveField(5)
  late String storyVideoLocation;

  @HiveField(6) // Add filter field
  String? storyVideoFilter;

  StoryModel({
    this.title = "",
    this.content = "",
    required this.storyVideoPath,
    this.storyVideoDate,
    this.storyVideoTime,
    this.storyVideoLocation = "",
    this.storyVideoFilter = "original",
  });
}
