
class Article {
  final String aid;
  final String title;
  final String name;
  final List<String> content;
  final bool isActive;
  final String image;

  Article({
    required this.aid,
    required this.title,
    required this.name,
    required this.content,
    required this.isActive,
    required this.image,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    aid: json['aid']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    content: List<String>.from(json['content'] ?? []),
    isActive: json['isActive'] ?? true,
    image: json['image']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'aid': aid,
    'title': title,
    'content': content,
    'isActive': isActive,
    'image': image,
  };
}
