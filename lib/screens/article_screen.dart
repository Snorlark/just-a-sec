import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../custom/custom_text.dart';
import '../widgets/article_dialog.dart';
import '../screens/detail_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<void> _loadFuture;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadArticles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _filterArticles();
    });
  }

  void _filterArticles() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles
            .where((a) =>
                a.title.toLowerCase().contains(query) ||
                a.name.toLowerCase().contains(query) ||
                a.content.any((c) => c.toLowerCase().contains(query)))
            .toList();
      }
    });
  }

  Future<void> _loadArticles() async {
    try {
      final response = await ArticleService().getAllArticle();
      final articles = response.map((e) => Article.fromJson(e)).toList();
      setState(() {
        _allArticles = articles;
        _filteredArticles = articles;
      });
    } catch (e) {
      debugPrint('Error loading articles: $e');
    }
  }

  Future<void> _openAddArticleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => ArticleDialog(
        onSave: (payload) async {
          try {
            final response = await ArticleService().createArticle(payload);
            final created = (response['article'] ?? response);
            final newArticle = Article.fromJson(created);
            
            setState(() {
              _allArticles.insert(0, newArticle);
              _filterArticles();
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article added.')),
              );
            }
          } catch (e) {
            rethrow;
          }
        },
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: active ? Colors.green : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Articles',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Settings action
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Search text field must be here
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CustomText(
                          text: 'No equipment article to display...',
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                          SizedBox(height: 10.h),
                          const CustomText(
                            text: 'Waiting for the equipment articles to display...',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_filteredArticles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: const Center(
                      child: CustomText(
                        text: 'No equipment article to display...',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shrinkWrap: true,
                  itemCount: _filteredArticles.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    final preview = article.content.isNotEmpty ? article.content.first : '';
                    
                    return Card(
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          debugPrint('Tapped index $index: ${article.aid}');
                          // Navigation to DetailScreen must be here
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(article: article),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(15),
                            vertical: ScreenUtil().setHeight(15),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: article.title.isEmpty ? 'Untitled' : article.title,
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 2,
                                          ),
                                        ),
                                        _statusChip(article.isActive),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text: article.name,
                                      fontSize: 13.sp,
                                    ),
                                    if (preview.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      CustomText(
                                        text: preview,
                                        fontSize: 12.sp,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddArticleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
