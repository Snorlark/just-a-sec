// class Article {
//   final int userId;
//   final int id;
//   final String title;
//   final String body;
//   final String? image;

//   Article({
//     required this.userId,
//     required this.id,
//     required this.title,
//     required this.body,
//     this.image,
//   });

//   factory Article.fromJson(Map<String, dynamic> json) {
//     return Article(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//       body: json['body'],
//       image: json['image'] as String?,
//     );
//   }
// }
class Article {
  final String aid;
  final String title;
  final List<String> content;
  final bool isActive;

  Article({
    required this.aid,
    required this.title,
    required this.content,
    required this.isActive,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        aid: json['aid'],
        title: json['title'],
        content: List<String>.from(json['content'] ?? []),
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'aid': aid,
        'title': title,
        'content': content,
        'isActive': isActive,
      };
}
