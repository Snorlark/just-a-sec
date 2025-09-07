import '../config/constants.dart';
import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    // http.Response response = await http.get(Uri.parse('$host/posts'));
    Response response = await get(Uri.parse('$host/posts'));

    if (response.statusCode == 200) {
      listData = jsonDecode(response.body);

      return listData;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
