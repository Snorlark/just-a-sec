// import '../config/constants.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/article_model.dart';

// class ArticleService {
//   List listData = [];

//   // Add to the article_service.dart
//   Future<Map> createArticle(dynamic article) async {
//     final response = await http.post(
//       Uri.parse('host/api/articles'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(article),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       return data;
//     } else {
//       throw Exception(
//         'Failed to create article: ${response.statusCode} ${response.body}',
//       );
//     }
//   }

//   Future<Map> updateArticle(String id, dynamic article) async {
//     final response = await http.put(
//       Uri.parse('host/api/articles/$id'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(article),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       return data;
//     } else {
//       throw Exception(
//         'Failed to update article: ${response.statusCode} ${response.body}',
//       );
//     }
//   }

//   Future<List> getAllArticle() async {
//     try {
//       final uri = Uri.parse('$host/posts');
//       final response = await http.get(uri).timeout(const Duration(seconds: 8));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);

//         // ID → image mapping (extend as needed)
//         final Map<int, String> idToImage = {
//           1: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80',
//           2: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
//           3: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800&q=80',
//           4: 'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800&q=80',
//           5: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',
//           6: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
//         };

//         listData =
//             data.map((e) {
//               final m = Map<String, dynamic>.from(e as Map);
//               final id = (m['id'] as num?)?.toInt() ?? 0;
//               m['image'] =
//                   idToImage[id] ?? 'https://picsum.photos/seed/$id/800/600';
//               return m;
//             }).toList();

//         return listData;
//       } else {
//         return [];
//       }
//     } catch (_) {
//       return [];
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticleService {
  // Set your backend host here
  final String baseUrl = "https://advweb-backend.vercel.app";

  Future<dynamic> createArticle(Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/api/articles");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to save: ${response.body}");
    }
  }

  Future<dynamic> updateArticle(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/api/articles/$id");
    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchArticles() async {
    final uri = Uri.parse("$baseUrl/api/articles");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load articles: ${response.body}");
    }
  }
}
