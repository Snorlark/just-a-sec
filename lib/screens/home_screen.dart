import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:just_a_sec/config/constants.dart';
import 'package:just_a_sec/custom/custom_button_widget.dart';
import 'package:just_a_sec/custom/custom_record_button.dart';
import 'package:just_a_sec/models/story_model.dart';
import 'package:just_a_sec/services/camera_service.dart';
import 'package:just_a_sec/widgets/camera_widget.dart';
import 'package:just_a_sec/screens/video_posting_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoBack; // callback to go back to gallery

  const HomeScreen({super.key, required this.onGoBack});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final GlobalKey<CameraWidgetState> _cameraWidgetKey = GlobalKey();
  bool isFlashOn = false;
  bool isRecording = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _recordAndSaveStory() async {
    try {
      setState(() {
        isRecording = true;
      });

      final video = await _cameraService.recordOneSecondVideo();

      setState(() {
        isRecording = false;
      });

      if (video != null) {
        // Create story model with video path only - don't save to Hive yet
        final story = StoryModel(
          storyVideoPath: video.path,
          storyVideoDate: DateTime.now(),
          storyVideoTime: DateTime.now(),
          storyVideoLocation: "",
        );

        print('Video recorded: ${story.storyVideoPath}');

        // Navigate to VideoPostingScreen to handle the details and saving
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPostingScreen(story: story),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isRecording = false;
      });
      print('Error recording story: $e');
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    if (mounted) setState(() {});
  }

  Future<void> _toggleFlash() async {
    final newFlashMode = isFlashOn ? FlashMode.off : FlashMode.torch;
    await _cameraService.setFlashMode(newFlashMode);
    if (mounted) setState(() => isFlashOn = !isFlashOn);
  }

  Widget _buildRecordingIndicator() {
    if (!isRecording) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(_animation.value),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'REC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 400 ? 36.0 : 32.0;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: CustomButtonWidget(
              onPressed: widget.onGoBack, // <-- goes to gallery
              goBack: true,
            ),
          ),
          Stack(
            children: [
              CameraWidget(
                key: _cameraWidgetKey,
                cameraService: _cameraService,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: _buildRecordingIndicator(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: isRecording ? null : _toggleFlash,
                icon: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: isRecording ? Colors.grey : WHITE,
                  size: iconSize,
                ),
              ),
              CustomRecordButton(
                onPressed: isRecording ? null : _recordAndSaveStory,
              ),
              IconButton(
                onPressed: isRecording ? null : _switchCamera,
                icon: Icon(
                  Icons.switch_camera,
                  color: isRecording ? Colors.grey : WHITE,
                  size: iconSize,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
