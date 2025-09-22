import '../config/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ArticleService {
  List listData = [];

  // Add to the article_service.dart
  Future<Map> createArticle(dynamic article) async {
    final response = await http.post(
      Uri.parse('$host/api/articles'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        'Failed to create article: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map> updateArticle(String id, dynamic article) async {
    final response = await http.put(
      Uri.parse('$host/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        'Failed to update article: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List> getAllArticle() async {
    try {
      final uri = Uri.parse('$host/api/articles');
      print('Fetching articles from: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['articles'] ?? [];
        print('Parsed data length: ${data.length}');

        // ID → image mapping (extend as needed)
        final Map<int, String> idToImage = {
          1: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80',
          2: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
          3: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800&q=80',
          4: 'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800&q=80',
          5: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',
          6: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
        };

        listData =
            data.map((e) {
              final m = Map<String, dynamic>.from(e as Map);
              // Map '_id' to 'aid' for Article model compatibility
              m['aid'] = m['_id']?.toString() ?? '';
              // Generate a simple ID for image mapping
              final id = m['_id']?.hashCode ?? 0;
              m['image'] =
                  idToImage[id.abs() % 6 + 1] ?? 'https://picsum.photos/seed/${m['_id']}/800/600';
              return m;
            }).toList();

        print('Processed articles: ${listData.length}');
        return listData;
      } else {
        print('API returned status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }
}
