import 'package:flutter/material.dart';
import 'package:just_a_sec/config/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:math' as math;

// Import your models and widgets
import 'package:just_a_sec/models/story_model.dart';
import '../widgets/responsive_container_widget.dart';
import '../config/app_spacing.dart';
import '../custom/custom_button_widget.dart';
import '../custom/custom_icon_button.dart';
import '../custom/custom_record_button.dart';
import '../custom/custom_transition.dart';
import 'main_nav_screen.dart';

class VideoPostingScreen extends StatefulWidget {
  final StoryModel story;

  const VideoPostingScreen({super.key, required this.story});

  @override
  State<VideoPostingScreen> createState() => _VideoPostingScreenState();
}

class _VideoPostingScreenState extends State<VideoPostingScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;
  bool _isSaving = false;

  bool _isCreateText = false;
  bool _isEditFilter = false;
  bool _isLocation = false;
  bool _isMuted = false;

  String _selectedFilter = "original";
  List<String> _availableFilters = [
    "original",
    "blackwhite",
    "retro",
    "sepia",
    "vintage",
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Animation controllers for frame flipping and filter expansion
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _filterController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.easeOut),
    );

    _initializeVideoPlayer();
    _loadStoryData();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.story.storyVideoPath != null &&
          widget.story.storyVideoPath!.isNotEmpty) {
        final file = File(widget.story.storyVideoPath!);
        if (await file.exists()) {
          _videoController = VideoPlayerController.file(file);
          await _videoController!.initialize();

          setState(() {
            _isVideoInitialized = true;
            _isLoading = false;
          });

          // Auto-play and loop the video
          _videoController!.play();
          _videoController!.setLooping(true);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadStoryData() {
    _titleController.text = widget.story.title;
    _contentController.text = widget.story.content;
    _locationController.text = widget.story.storyVideoLocation;
    _selectedFilter = widget.story.storyVideoFilter!;
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to get location')));
    }
  }

  void _toggleTextCreation() {
    setState(() {
      _isCreateText = !_isCreateText;
    });

    if (_isCreateText) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _toggleFilterOptions() {
    setState(() {
      _isEditFilter = !_isEditFilter;
    });

    if (_isEditFilter) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _saveStory() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Update the story with new data
      widget.story.title = _titleController.text.trim();
      widget.story.content = _contentController.text.trim();
      widget.story.storyVideoLocation = _locationController.text.trim();
      widget.story.storyVideoFilter = _selectedFilter;

      // Save to Hive box
      final box = Hive.box<StoryModel>('storyBox');
      await box.add(widget.story);

      print('Story saved to Hive: ${widget.story.storyVideoPath}');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a bit then go back
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(
          context,
        ).pushReplacement(CustomTransition(page: MainNavScreen()));
      }
    } catch (e) {
      print('Error saving story: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving story. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _discardStory() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(
              255,
              177,
              176,
              176,
            ).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Discard Story?',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to discard this story? This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: PRIMARY,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: PRIMARY),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: PRIMARY,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Discard',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (shouldDiscard == true) {
      try {
        // Delete video file if it exists
        if (widget.story.storyVideoPath != null) {
          final file = File(widget.story.storyVideoPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error discarding story: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error discarding story. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildVideoFrame() {
    final double boxHeight = MediaQuery.of(context).size.height * 0.6;
    final double boxWidth = MediaQuery.of(context).size.width * 0.8;

    return SizedBox(
      height: boxHeight,
      width: boxWidth,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * math.pi),
            child: isShowingFront ? _buildVideoPlayer() : _buildTextEditor(),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final double boxHeight = MediaQuery.of(context).size.height * 0.6;
    final double boxWidth = MediaQuery.of(context).size.width * 0.8;

    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        height: boxHeight,
        width: boxWidth,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No video available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video player with filter
            ColorFiltered(
              colorFilter: _getColorFilter(_selectedFilter),
              child: VideoPlayer(_videoController!),
            ),
            // Play/Pause overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Location overlay
            if (_locationController.text.isNotEmpty)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Location Added',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _buildTextEditor() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Film',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleTextCreation,
                    child: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Title field
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter story title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: PRIMARY),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 1,
              ),

              const SizedBox(height: 20),

              // Content field
              Text(
                'Caption',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Write your story caption...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PRIMARY),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleTextCreation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _filterAnimation.value,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: _filterAnimation.value,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterChip(
                    label: Text("Original"),
                    selected: _selectedFilter == 'original',
                    onSelected:
                        (_) => setState(() => _selectedFilter = 'original'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text("B&W"),
                    selected: _selectedFilter == 'blackwhite',
                    onSelected:
                        (_) => setState(() => _selectedFilter = 'blackwhite'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text("Retro"),
                    selected: _selectedFilter == 'retro',
                    onSelected:
                        (_) => setState(() => _selectedFilter = 'retro'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text("Vintage"),
                    selected: _selectedFilter == 'vintage',
                    onSelected:
                        (_) => setState(() => _selectedFilter = 'vintage'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text("Sepia"),
                    selected: _selectedFilter == 'Sepia',
                    onSelected:
                        (_) => setState(() => _selectedFilter = 'sepia'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ColorFilter _getColorFilter(String filter) {
    switch (filter) {
      case 'blackwhite':
        return ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'sepia':
        return ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'retro':
        return ColorFilter.matrix([
          1.0,
          0.2,
          0.2,
          0,
          0,
          0.2,
          1.0,
          0.2,
          0,
          0,
          0.2,
          0.2,
          1.0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'vintage':
        return ColorFilter.matrix([
          0.6,
          0.3,
          0.1,
          0,
          0,
          0.2,
          0.8,
          0.1,
          0,
          0,
          0.1,
          0.2,
          0.7,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      default:
        return ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'original':
        return 'Original';
      case 'blackwhite':
        return 'B&W';
      case 'sepia':
        return 'Sepia';
      case 'retro':
        return 'Retro';
      case 'vintage':
        return 'Vintage';
      default:
        return filter;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _filterController.dispose();
    _videoController?.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 400 ? 36.0 : 32.0;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ResponsiveContainerWidget(
                child: Padding(
                  padding: AppSpacing.allMargin,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back button
                          Align(
                            alignment: Alignment.topLeft,
                            child: CustomButtonWidget(
                              onPressed: _discardStory,
                              goBack: true,
                            ),
                          ),

                          // Main video frame container
                          Stack(
                            children: [
                              Center(child: _buildVideoFrame()),

                              // Side controls (only show when not in text editing mode)
                              if (!_isCreateText)
                                Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          right: 30,
                                        ),
                                        child: Column(
                                          children: [
                                            CustomIconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isMuted = !_isMuted;
                                                  _videoController?.setVolume(
                                                    _isMuted ? 0.0 : 1.0,
                                                  );
                                                });
                                              },
                                              iconLogo:
                                                  _isMuted
                                                      ? Icons.volume_off_rounded
                                                      : Icons.volume_up_rounded,
                                            ),
                                            SizedBox(height: 15),
                                            CustomIconButton(
                                              onPressed: _getCurrentLocation,
                                              iconLogo:
                                                  _isLocation
                                                      ? Icons.location_pin
                                                      : Icons.location_off,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Bottom controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: _toggleTextCreation,
                                icon: Icon(
                                  Icons.text_fields,
                                  color:
                                      _isCreateText
                                          ? WHITE.withOpacity(0.8)
                                          : WHITE,
                                  size: iconSize,
                                ),
                              ),
                              CustomRecordButton(
                                isUpload: true,
                                onPressed: _isSaving ? null : _saveStory,
                              ),
                              IconButton(
                                onPressed: _toggleFilterOptions,
                                icon: Icon(
                                  Icons.photo_filter,
                                  color: _isEditFilter ? PRIMARY : WHITE,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Filter options overlay
                      if (_isEditFilter)
                        Positioned(
                          bottom: 120,
                          left: 0,
                          right: 0,
                          child: _buildFilterOptions(),
                        ),

                      // Loading overlay
                      if (_isSaving)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: PRIMARY),
                                const SizedBox(height: 16),
                                Text(
                                  'Saving your story...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
