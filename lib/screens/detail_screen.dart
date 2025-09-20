import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../custom/custom_text.dart';
import '../custom/custom_text_field.dart';
import '../custom/custom_button_widget.dart';
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
    _contentController = TextEditingController(text: widget.article.content.join('\n'));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: _isEditMode ? _titleController.text : widget.article.title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditMode = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {}, // Settings action
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Image placeholder
                Container(
                  height: 260.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
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
                ),
                // Content area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: _isEditMode ? _buildEditForm() : _buildViewContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
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

  Widget _buildViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.article.title,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: PRIMARY,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: widget.article.name,
          fontSize: 15.sp,
          color: PRIMARY.withOpacity(0.85),
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 16.h),
        // Content list
        ...widget.article.content.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.only(top: 8.h, right: 12.w),
                decoration: BoxDecoration(
                  color: PRIMARY,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: CustomText(
                  text: item,
                  fontSize: 15.sp,
                  color: PRIMARY.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )).toList(),
        SizedBox(height: 16.h),
        Center(
          child: CustomButtonWidget(
            onPressed: () => setState(() => _isEditMode = true),
            text: 'Edit Article',
            isTextButton: true,
            textButtonWidth: 180,
            textButtonHeight: 44,
            textButtonMargin: const EdgeInsets.symmetric(horizontal: 0),
            textButtonBorderColor: PRIMARY,
            textButtonBorderWidth: 2,
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
          CustomText(
            text: 'Title',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: PRIMARY,
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _titleController,
            hintText: 'Enter title',
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Author / Name',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: PRIMARY,
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _authorController,
            hintText: 'Enter author name',
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Content (one item per line or comma-separated)',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: PRIMARY,
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _contentController,
            hintText: 'Enter content items',
            maxLines: 6,
            validator: (v) {
              final items = v == null ? <String>[] : _toList(v);
              return items.isEmpty ? 'At least one content item' : null;
            },
          ),
          SizedBox(height: 16.h),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const CustomText(
              text: 'Active',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                  onPressed: _cancelEdit,
                  text: 'Cancel',
                  isTextButton: true,
                  textButtonWidth: double.infinity,
                  textButtonHeight: 44,
                  textButtonMargin: const EdgeInsets.symmetric(horizontal: 0),
                  textButtonBorderColor: Colors.grey,
                  textButtonBorderWidth: 2,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: _saveChanges,
                  text: 'Save Changes',
                  textButtonWidth: double.infinity,
                  textButtonHeight: 44,
                  textButtonMargin: const EdgeInsets.symmetric(horizontal: 0),
                  textButtonColor: PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: CustomText(
              text: 'Tip: separate multiple content items using new lines or commas.',
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
