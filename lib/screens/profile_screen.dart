import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/article_model.dart';
import '../services/article_service.dart';
import '../custom/custom_text.dart';
import '../providers/theme_provider.dart';
import '../config/constants.dart';
import '../custom/custom_button_widget.dart';

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

    return Scaffold( 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/main');
            }
          },
        ),
        title: const CustomText(
          text: 'Articles',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with theme toggle
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
            child: Row(
              children: [
                // Expanded(
                //   child: CustomText(
                //     text: 'Articles',
                //     fontSize: 26.sp,
                //     fontWeight: FontWeight.w700,
                //     color: Colors.white,
                //   ),
                // ),
                // Row(
                //   children: const [],
                // ),
                // Switch(
                //   value: themeProvider.isDark,
                //   onChanged: (val) {
                //     context.read<ThemeProvider>().setDark(val);
                //     _persistTheme(val);
                //   },
                // ),
                // const Icon(Icons.nightlight_round, color: Colors.white),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16.sp),
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

          // Articles section title using splash typography (kept white)
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 20.w),
          //   child: Text(
          //     'Articles',
          //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //           color: Colors.white,
          //           fontWeight: FontWeight.w700,
          //         ),
          //   ),
          // ),
          // SizedBox(height: 8.h),

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
                              // Image placeholder with PRIMARY border
                              Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: PRIMARY, width: 2),
                                  image: (article.image != null && article.image!.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(article.image!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: (article.image != null && article.image!.isNotEmpty)
                                    ? null
                                    : Icon(Icons.image, color: Colors.blueAccent, size: 28.sp),
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
                                      fontWeight: FontWeight.w800,
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
    ),
    );
  }
}

class _ArticleDetailPage extends StatelessWidget {
  const _ArticleDetailPage({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Illustration header with white background
            Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                image: (article.image != null && article.image!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(article.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (article.image != null && article.image!.isNotEmpty)
                  ? null
                  : Center(
                      child: Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: PRIMARY, width: 3),
                        ),
                        child: Icon(
                          Icons.travel_explore,
                          size: 80.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
            ),
            // Content area with white background and brown text
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: article.title,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: PRIMARY,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: article.body,
                        fontSize: 15.sp,
                        color: PRIMARY.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: CustomButtonWidget(
                          onPressed: () {},
                          text: 'Read All',
                          isTextButton: true,
                          textButtonWidth: 180,
                          textButtonHeight: 44,
                          textButtonMargin: const EdgeInsets.symmetric(horizontal: 0),
                          textButtonBorderColor: PRIMARY,
                          textButtonBorderWidth: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
