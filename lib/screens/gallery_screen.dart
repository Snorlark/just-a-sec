import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';
import 'package:just_a_sec/models/story_model.dart';
import 'dart:io';
import 'dart:math' as math;

import '../models/user_model.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with TickerProviderStateMixin {
  late Box<UserModel> _userBox;
  late Box<StoryModel> _storyBox;
  UserModel? _user;
  bool _isLoading = true;

  List<StoryModel> _stories = [];
  Map<int, VideoPlayerController> _controllers = {};
  Map<int, bool> _controllersInitialized = {};

  PageController _pageController = PageController();
  int _currentIndex = 0;

  // View mode - true for polaroid view, false for grid view
  bool _isPolaroidView = true;

  // Maximum number of video controllers to keep in memory
  static const int _maxControllers = 2;

  // Animation controllers for frame flipping
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _loadUserInfo();
      await _loadStory();
      if (_stories.isNotEmpty) {
        _initializeCurrentVideo();
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    _userBox = await Hive.openBox<UserModel>('userBox');
    final user = _userBox.get('currentUser');

    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _loadStory() async {
    try {
      _storyBox = await Hive.openBox<StoryModel>('storyBox');
      _stories = _storyBox.values.toList();

      // Sort by date - latest first
      _stories.sort((a, b) {
        if (a.storyVideoDate == null && b.storyVideoDate == null) return 0;
        if (a.storyVideoDate == null) return 1;
        if (b.storyVideoDate == null) return -1;
        return b.storyVideoDate!.compareTo(a.storyVideoDate!);
      });
    } catch (e) {
      print('Error loading story: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeVideoController(int index) async {
    if (_controllers.containsKey(index) || index >= _stories.length) return;

    final story = _stories[index];
    if (story.storyVideoPath == null) return;

    try {
      final file = File(story.storyVideoPath!);
      if (!await file.exists()) {
        print('Video file does not exist: ${story.storyVideoPath}');
        return;
      }

      // Clean up old controllers if we have too many
      await _cleanupDistantControllers(index);

      final controller = VideoPlayerController.file(file);
      _controllers[index] = controller;

      await controller.initialize();
      controller.setLooping(true);

      if (mounted) {
        setState(() {
          _controllersInitialized[index] = true;
        });
      }
    } catch (e) {
      print('Error initializing video player for index $index: $e');
      // Clean up on error
      if (_controllers.containsKey(index)) {
        _controllers[index]?.dispose();
        _controllers.remove(index);
        _controllersInitialized.remove(index);
      }
    }
  }

  Future<void> _cleanupDistantControllers(int currentIndex) async {
    if (_controllers.length <= _maxControllers) return;

    // Find controllers that are farthest from current index
    final distantIndices =
        _controllers.keys
            .where((index) => (index - currentIndex).abs() > 1)
            .toList()
          ..sort(
            (a, b) =>
                (b - currentIndex).abs().compareTo((a - currentIndex).abs()),
          );

    // Dispose controllers that are too far away
    for (
      int i = 0;
      i < distantIndices.length && _controllers.length > _maxControllers;
      i++
    ) {
      final index = distantIndices[i];
      await _disposeController(index);
    }
  }

  Future<void> _disposeController(int index) async {
    if (!_controllers.containsKey(index)) return;

    try {
      await _controllers[index]?.pause();
      await _controllers[index]?.dispose();
    } catch (e) {
      print('Error disposing controller $index: $e');
    } finally {
      _controllers.remove(index);
      _controllersInitialized.remove(index);
    }
  }

  void _initializeCurrentVideo() {
    if (!_isPolaroidView) return; // Don't initialize videos in grid view

    _initializeVideoController(_currentIndex);
    // Only pre-load one adjacent video to save memory
    if (_currentIndex > 0) {
      _initializeVideoController(_currentIndex - 1);
    } else if (_currentIndex < _stories.length - 1) {
      _initializeVideoController(_currentIndex + 1);
    }
  }

  void _onPageChanged(int index) {
    // Pause all videos first
    for (var controller in _controllers.values) {
      controller.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    // Initialize and play new video
    _initializeCurrentVideo();
    if (_controllers.containsKey(index) &&
        _controllersInitialized[index] == true) {
      _controllers[index]!.play();
    }

    // Clean up distant controllers after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _cleanupDistantControllers(index);
      }
    });
  }

  void _toggleFlip() {
    if (!_isPolaroidView) return;

    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _toggleView() {
    setState(() {
      _isPolaroidView = !_isPolaroidView;
      _isFlipped = false; // Reset flip state when switching views
    });
    _flipController.reset();

    // Clean up all video controllers when switching to grid view
    if (!_isPolaroidView) {
      for (var controller in _controllers.values) {
        controller.pause();
      }
    } else {
      // Initialize current video when switching back to polaroid view
      _initializeCurrentVideo();
    }
  }

  Future<void> _deleteStory(int index) async {
    if (index < 0 || index >= _stories.length) return;

    final story = _stories[index];

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Story'),
            content: const Text(
              'Are you sure you want to delete this story? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      // Dispose video controller if exists
      if (_controllers.containsKey(index)) {
        await _disposeController(index);
      }

      // Delete from Hive
      final storyKey = _storyBox.keys.firstWhere(
        (key) => _storyBox.get(key) == story,
        orElse: () => null,
      );

      if (storyKey != null) {
        await _storyBox.delete(storyKey);
      }

      // Update local list
      setState(() {
        _stories.removeAt(index);

        // Adjust current index if necessary
        if (_currentIndex >= _stories.length && _stories.isNotEmpty) {
          _currentIndex = _stories.length - 1;
        }

        // Update controller indices
        final newControllers = <int, VideoPlayerController>{};
        final newInitialized = <int, bool>{};

        for (var entry in _controllers.entries) {
          if (entry.key < index) {
            newControllers[entry.key] = entry.value;
            newInitialized[entry.key] =
                _controllersInitialized[entry.key] ?? false;
          } else if (entry.key > index) {
            newControllers[entry.key - 1] = entry.value;
            newInitialized[entry.key - 1] =
                _controllersInitialized[entry.key] ?? false;
          }
        }

        _controllers = newControllers;
        _controllersInitialized = newInitialized;
      });

      // Navigate to valid page
      if (_stories.isNotEmpty && _isPolaroidView) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _initializeCurrentVideo();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting story: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete story')));
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();

    // Dispose all video controllers properly
    for (var controller in _controllers.values) {
      controller.pause().then((_) => controller.dispose()).catchError((e) {
        print('Error disposing controller: $e');
      });
    }
    _controllers.clear();
    _controllersInitialized.clear();
    _pageController.dispose();

    super.dispose();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _toggleView,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPolaroidView ? Icons.grid_view : Icons.view_carousel,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
          ),
          if (_isPolaroidView && _stories.isNotEmpty)
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleFlip,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flip_to_back,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _deleteStory(_currentIndex),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[700],
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: _stories.length,
      itemBuilder: (context, index) {
        final story = _stories[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
              _isPolaroidView = true;
            });
            _initializeCurrentVideo();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child:
                        story.storyVideoPath != null
                            ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(color: Colors.grey[300]),
                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const Center(
                              child: Icon(
                                Icons.video_library_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (story.title.isNotEmpty)
                          Text(
                            story.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (story.storyVideoDate != null)
                          Text(
                            _formatDateShort(story.storyVideoDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolaroidFrame(StoryModel story, int index) {
    final isInitialized = _controllersInitialized[index] ?? false;
    final controller = _controllers[index];
    final screenHeight = MediaQuery.of(context).size.height;
    final polaroidHeight =
        screenHeight * 0.65; // Reduced height to prevent memory issues

    return Container(
      height: polaroidHeight,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
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
            child:
                isShowingFront
                    ? _buildFrontFrame(story, controller, isInitialized)
                    : _buildBackFrame(story),
          );
        },
      ),
    );
  }

  Widget _buildFrontFrame(
    StoryModel story,
    VideoPlayerController? controller,
    bool isInitialized,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Video/Image area
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildVideoContent(story, controller, isInitialized),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title area
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (story.title.isNotEmpty)
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Cursive',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    if (story.storyVideoDate != null)
                      Text(
                        _formatDate(story.storyVideoDate!),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildBackFrame(StoryModel story) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
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
              // Date header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (story.storyVideoDate != null)
                    Text(
                      _formatDateShort(story.storyVideoDate!),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (story.storyVideoTime != null)
                    Text(
                      _formatTime(story.storyVideoTime!),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              // Title
              Center(
                child: Text(
                  story.title.isNotEmpty ? story.title : "Caption this moment",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    story.content.isNotEmpty
                        ? story.content
                        : "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(
    StoryModel story,
    VideoPlayerController? controller,
    bool isInitialized,
  ) {
    if (story.storyVideoPath == null) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'No video available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    if (!isInitialized || controller == null) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          });
        }
      },
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            // Play/Pause overlay
            AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            // Video controls overlay
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
                      story.storyVideoLocation!.isNotEmpty
                          ? story.storyVideoLocation!
                          : 'Add Location',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.volume_up, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.month}/${date.day}/${date.year % 100}';
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stories.isEmpty) {
      return const Center(
        child: Text(
          'No stories found.\nRecord a video first!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Fixed app bar
        _buildAppBar(),

        // Main content area
        Expanded(
          child:
              _isPolaroidView
                  ? PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    scrollDirection: Axis.vertical,
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return _buildPolaroidFrame(_stories[index], index);
                    },
                  )
                  : _buildGridView(),
        ),
      ],
    );
  }
}
