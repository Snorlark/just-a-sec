import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../custom/custom_text.dart';
import '../custom/custom_text_field.dart';
import '../config/constants.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditMode = false;
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _contentController;
  late bool _isActive;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _authorController = TextEditingController(text: widget.article.name);
    _contentController = TextEditingController(
      text: widget.article.content.join('\n'),
    );
    _isActive = widget.article.isActive;
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  List<String> _toList(String raw) {
    return raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final payload = {
        'title': _titleController.text.trim(),
        'name': _authorController.text.trim(),
        'content': _toList(_contentController.text),
        'isActive': _isActive,
      };

      await ArticleService().updateArticle(widget.article.aid, payload);

      setState(() => _isEditMode = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _titleController.text = widget.article.title;
      _authorController.text = widget.article.name;
      _contentController.text = widget.article.content.join('\n');
      _isActive = widget.article.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [              
              SliverAppBar(
                expandedHeight: 280.h,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  if (!_isEditMode)
                    Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => setState(() => _isEditMode = true),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.article.image.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.article.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildFallbackImage();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Title overlay
                            Positioned(
                              bottom: 20.h,
                              left: 20.w,
                              right: 20.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: _isEditMode ? _titleController.text : widget.article.title,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        color: Colors.white70,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      CustomText(
                                        text: widget.article.name,
                                        fontSize: 16.sp,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.article.isActive
                                              ? Colors.green
                                              : Colors.grey[600],
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: CustomText(
                                          text: widget.article.isActive ? 'Active' : 'Inactive',
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _buildFallbackImage(),
                ),
              ),
              // Content area
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: _isEditMode ? _buildEditForm() : _buildViewContent(),
                  ),
                ),
              ),
            ],
          ),
          // Loading overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator.adaptive(
                        strokeWidth: 3.sp,
                        valueColor: AlwaysStoppedAnimation<Color>(PRIMARY),
                      ),
                      SizedBox(height: 16.h),
                      const CustomText(
                        text: 'Updating article...',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PRIMARY, PRIMARY.withOpacity(0.8)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: 40.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Article Image',
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Article details card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: PRIMARY,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Article Details',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildDetailRow(
                icon: Icons.title,
                label: 'Title',
                value: widget.article.title,
              ),
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: Icons.person,
                label: 'Author',
                value: widget.article.name,
              ),
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: widget.article.isActive ? Icons.check_circle : Icons.cancel,
                label: 'Status',
                value: widget.article.isActive ? 'Active' : 'Inactive',
                valueColor: widget.article.isActive ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        
        // Content section
        Row(
          children: [
            Icon(
              Icons.list_alt,
              color: PRIMARY,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: 'Content',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Content
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: widget.article.content.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: index < widget.article.content.length - 1
                      ? Border(
                          bottom: BorderSide(color: Colors.grey[100]!),
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: CustomText(
                          text: '${index + 1}',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: PRIMARY,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomText(
                        text: item,
                        fontSize: 16.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        SizedBox(height: 32.h),
        
        // Edit button
        Center(
          child: Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [PRIMARY, PRIMARY.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: PRIMARY.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25.r),
                onTap: () => setState(() => _isEditMode = true),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: 'Edit Article',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 2.h),
              CustomText(
                text: value,
                fontSize: 16.sp,
                color: valueColor ?? Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: PRIMARY.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: PRIMARY,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                CustomText(
                  text: 'Edit Article',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: PRIMARY,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Title field
          _buildFormField(
            label: 'Title',
            icon: Icons.title,
            child: CustomTextField(
              controller: _titleController,
              hintText: 'Enter article title',
              validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
            ),
          ),
          SizedBox(height: 20.h),

          // Author field
          _buildFormField(
            label: 'Author',
            icon: Icons.person,
            child: CustomTextField(
              controller: _authorController,
              hintText: 'Enter author name',
              validator: (v) => v?.trim().isEmpty == true ? 'Author is required' : null,
            ),
          ),
          SizedBox(height: 20.h),

          // Content field
          _buildFormField(
            label: 'Content',
            icon: Icons.list_alt,
            child: CustomTextField(
              controller: _contentController,
              hintText: 'Enter content items (one per line or comma-separated)',
              maxLines: 6,
              validator: (v) {
                final items = v == null ? <String>[] : _toList(v);
                return items.isEmpty ? 'At least one content item is required' : null;
              },
            ),
          ),
          SizedBox(height: 20.h),

          // Status toggle
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Article Status',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: _isActive ? 'Active' : 'Inactive',
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25.r),
                      onTap: _cancelEdit,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: 'Cancel',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [PRIMARY, PRIMARY.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: PRIMARY.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25.r),
                      onTap: _saveChanges,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: 'Save Changes',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Tip
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[600],
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomText(
                    text: 'Tip: Separate multiple content items using new lines or commas.',
                    fontSize: 16.sp,
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: PRIMARY,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: label,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
