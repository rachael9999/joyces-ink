import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String) onTranscriptionUpdate;
  final Function(String?) onRecordingComplete;

  const VoiceRecordingWidget({
    Key? key,
    required this.onTranscriptionUpdate,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  String _recordingPath = '';
  String _transcription = '';
  Duration _recordingDuration = Duration.zero;

  // Apple-style animation controllers
  late AnimationController _breathingController;
  late AnimationController _waveController;
  late AnimationController _scaleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Subtle breathing animation for recording state
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Wave animation for active recording
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation for button press
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    // Apple-style haptic feedback
    if (!kIsWeb) {
      HapticFeedback.mediumImpact();
    }

    _scaleController.forward().then((_) => _scaleController.reverse());

    try {
      if (!await _requestMicrophonePermission()) {
        _showPermissionDeniedAlert();
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        String path;
        if (kIsWeb) {
          path = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: path,
          );
        } else {
          final dir = await getTemporaryDirectory();
          path =
              '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );
        }

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });

        _breathingController.repeat(reverse: true);
        _waveController.repeat();
        _startDurationTimer();
      }
    } catch (e) {
      _showErrorAlert('Unable to start recording. Please try again.');
    }
  }

  Future<void> _pauseRecording() async {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }

    try {
      await _audioRecorder.pause();
      setState(() {
        _isPaused = true;
      });
      _breathingController.stop();
      _waveController.stop();
    } catch (e) {
      _showErrorAlert('Unable to pause recording.');
    }
  }

  Future<void> _resumeRecording() async {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }

    try {
      await _audioRecorder.resume();
      setState(() {
        _isPaused = false;
      });
      _breathingController.repeat(reverse: true);
      _waveController.repeat();
    } catch (e) {
      _showErrorAlert('Unable to resume recording.');
    }
  }

  Future<void> _stopRecording() async {
    if (!kIsWeb) {
      HapticFeedback.mediumImpact();
    }

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      _breathingController.stop();
      _waveController.stop();
      _breathingController.reset();
      _waveController.reset();

      widget.onRecordingComplete(path);
      _simulateTranscription();
    } catch (e) {
      _showErrorAlert('Unable to complete recording.');
    }
  }

  void _simulateTranscription() {
    const sampleText =
        "Today was an incredible day filled with new discoveries and meaningful connections...";
    int currentIndex = 0;

    void addNextWord() {
      if (currentIndex < sampleText.length) {
        final nextSpace = sampleText.indexOf(' ', currentIndex);
        final endIndex = nextSpace == -1 ? sampleText.length : nextSpace + 1;

        setState(() {
          _transcription = sampleText.substring(0, endIndex);
        });

        widget.onTranscriptionUpdate(_transcription);
        currentIndex = endIndex;

        if (currentIndex < sampleText.length) {
          Future.delayed(const Duration(milliseconds: 150), addNextWord);
        }
      }
    }

    addNextWord();
  }

  void _deleteRecording() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingPath = '';
      _transcription = '';
      _recordingDuration = Duration.zero;
    });

    _breathingController.stop();
    _waveController.stop();
    _breathingController.reset();
    _waveController.reset();

    widget.onTranscriptionUpdate('');
    widget.onRecordingComplete(null);
  }

  void _startDurationTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && !_isPaused) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
        });
        _startDurationTimer();
      }
    });
  }

  void _showPermissionDeniedAlert() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Microphone Access'),
            content: const Text(
              'Please allow microphone access in Settings to record voice notes.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
    );
  }

  void _showErrorAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Recording Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _waveController.dispose();
    _scaleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordingButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale:
              _scaleAnimation.value *
              (_isRecording && !_isPaused ? _breathingAnimation.value : 1.0),
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _isRecording
                      ? (_isPaused
                          ? CupertinoColors.systemOrange
                          : CupertinoColors.systemRed)
                      : CupertinoColors.systemBlue,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording
                          ? (_isPaused
                              ? CupertinoColors.systemOrange
                              : CupertinoColors.systemRed)
                          : CupertinoColors.systemBlue)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: _isRecording ? 5 : 0,
                ),
              ],
            ),
            child: Icon(
              _isRecording
                  ? (_isPaused
                      ? CupertinoIcons.play_circle
                      : CupertinoIcons.stop_circle)
                  : CupertinoIcons.mic,
              color: CupertinoColors.white,
              size: 7.w,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 8.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(7, (index) {
              final delay = index * 0.15;
              final animationValue = (_waveController.value + delay) % 1.0;
              final height = 1.5.h + (5.h * math.sin(animationValue * math.pi));

              return Container(
                width: 0.8.w,
                height: height.abs(),
                margin: EdgeInsets.symmetric(horizontal: 0.3.w),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(0.4.w),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.all(3.w),
      borderRadius: BorderRadius.circular(50),
      color:
          isDestructive
              ? CupertinoColors.systemRed.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.1),
      onPressed: onPressed,
      child: Icon(icon, color: color, size: 5.w), minimumSize: Size(0, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.w),
      child: Column(
        children: [
          // Main Recording Button
          GestureDetector(
            onTap:
                _isRecording
                    ? (_isPaused ? _resumeRecording : _pauseRecording)
                    : _startRecording,
            child: _buildRecordingButton(),
          ),

          SizedBox(height: 4.h),

          // Recording Duration with Apple-style typography
          if (_isRecording || _recordingDuration.inSeconds > 0)
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
                letterSpacing: 0.5,
              ),
            ),

          SizedBox(height: 2.h),

          // Recording Status with subtle styling
          Text(
            _isRecording
                ? (_isPaused ? 'Paused' : 'Recording')
                : (_recordingDuration.inSeconds > 0
                    ? 'Tap to transcribe'
                    : 'Tap to record'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
              letterSpacing: 0.2,
            ),
          ),

          SizedBox(height: 4.h),

          // Apple-style Waveform
          if (_isRecording && !_isPaused)
            _buildWaveform()
          else if (_isRecording || _recordingDuration.inSeconds > 0)
            SizedBox(height: 8.h),

          SizedBox(height: 3.h),

          // Control Buttons with Apple styling
          if (_isRecording || _recordingDuration.inSeconds > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  onPressed: _deleteRecording,
                  isDestructive: true,
                ),
                if (_isRecording)
                  _buildControlButton(
                    icon: CupertinoIcons.stop,
                    color: CupertinoColors.systemBlue,
                    onPressed: _stopRecording,
                  ),
              ],
            ),

          SizedBox(height: 5.h),

          // Transcription with Apple-style card design
          if (_transcription.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: CupertinoColors.separator.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transcription',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemBlue,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _transcription,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.label,
                      height: 1.4,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}