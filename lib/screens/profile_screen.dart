import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../widgets/responsive_container_widget.dart';

import '../models/article_model.dart';
import '../services/article_service.dart';
import '../custom/custom_text.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _futureArticles = _getAllArticles();
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
      final query = _searchController.text.trim().toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredArticles = _allArticles;
        } else {
          _filteredArticles = _allArticles
              .where((a) =>
                  a.title.toLowerCase().contains(query) ||
                  a.body.toLowerCase().contains(query))
              .toList();
        }
      });
    });
  }

  Future<List<Article>> _getAllArticles() async {
    final response = await ArticleService().getAllArticle();
    final articles = (response).map((e) => Article.fromJson(e)).toList();
    _allArticles = articles;
    _filteredArticles = articles;
    return articles;
  }

  Future<void> _persistTheme(bool isDark) async {
    final box = await Hive.openBox('settingsBox');
    await box.put('darkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.95);
    final fieldBorder = isDark ? Colors.white24 : Colors.black26;
    final fieldHint = isDark ? Colors.white70 : Colors.black45;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with theme toggle
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text:'Articles',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    // textAlign: TextAlign.left,
                    // size: 26.sp,
                    // style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    // color: Colors.white.withOpacity(0.8),
                    
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, color: textSecondary),
                    Switch(
                      value: themeProvider.isDark,
                      onChanged: (val) {
                        context.read<ThemeProvider>().setDark(val);
                        _persistTheme(val);
                      },
                    ),
                    Icon(Icons.nightlight_round, color: textSecondary),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textPrimary, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                hintStyle: TextStyle(color: fieldHint, fontSize: 16.sp),
                prefixIcon: Icon(Icons.search, color: fieldHint),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // List
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No articles to display.',
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(strokeWidth: 3.5.sp),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: 'Loading articles...',
                          fontSize: 14.sp,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  );
                }

                final items = _filteredArticles;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No articles to display.',
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final article = items[index];
                    return Card(
                      color: cardBg,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ArticleDetailPage(article: article),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Placeholder for thumbnail/illustration
                              Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.image, color: Colors.blueAccent, size: 28.sp),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: article.title,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    CustomText(
                                      text: article.body,
                                      fontSize: 13.sp,
                                      color: textSecondary,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
          ),
        ],
      ),
    );
  }
}

class _ArticleDetailPage extends StatelessWidget {
  const _ArticleDetailPage({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Illustration header like reference screenshot
            Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
              ),
              child: Center(
                child: Icon(
                  Icons.travel_explore,
                  size: 120.sp,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Read All'),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: article.title,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    SizedBox(height: 8.h),
                    CustomText(
                      text: article.body,
                      fontSize: 15.sp,
                      color: textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
