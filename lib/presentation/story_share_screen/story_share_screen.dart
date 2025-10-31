import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/share_service.dart';
import '../../services/story_service.dart';

class StoryShareScreen extends StatefulWidget {
  const StoryShareScreen({super.key});

  @override
  State<StoryShareScreen> createState() => _StoryShareScreenState();
}

class _StoryShareScreenState extends State<StoryShareScreen> {
  final GlobalKey _captureKey = GlobalKey();
  String _title = '';
  String _content = '';
  String? _genre;
  String? _storyId;
  ShareAssets? _assets;
  bool _isGenerating = false;
  bool _usePresetCanvas = true;
  String _preset = 'IG Portrait (1080x1350)';

  @override
  void initState() {
    super.initState();
    // Defer reading ModalRoute until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _title = (args['title'] as String?) ?? '';
        _content = (args['content'] as String?) ?? '';
        _genre = args['genre'] as String?;
        _storyId = args['storyId']?.toString();
      }
      _prepareAssets();
    });
  }

  Future<void> _prepareAssets() async {
    if (_content.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Missing story content for sharing');
      return;
    }
    setState(() => _isGenerating = true);
    try {
      // If we have a storyId, try to read persisted clip first
      if (_storyId != null) {
        final story = await StoryService.instance.getGeneratedStory(_storyId!);
        final clip = (story?['share_clip'] as String?)?.trim();
        if (clip != null && clip.isNotEmpty) {
          setState(() {
            _assets = ShareAssets(
              clip: clip,
              imagePrompt: 'static-bg',
              imageBytes: Uint8List(0), // static asset background
            );
          });
          return;
        }
        // No persisted clip: generate one and persist it for reuse
        final newClip = await ShareService.instance.generateClipOnly(
          title: _title,
          storyContent: _content,
          genre: _genre,
        );
        try {
          await StoryService.instance.updateGeneratedStory(
            storyId: _storyId!,
            shareClip: newClip,
          );
        } catch (_) {}
        setState(() {
          _assets = ShareAssets(
            clip: newClip,
            imagePrompt: 'static-bg',
            imageBytes: Uint8List(0),
          );
        });
        return;
      }

      // No storyId: generate clip-only transiently
      final onlyClip = await ShareService.instance.generateClipOnly(
        title: _title,
        storyContent: _content,
        genre: _genre,
      );
      setState(() {
        _assets = ShareAssets(
          clip: onlyClip,
          imagePrompt: 'static-bg',
          imageBytes: Uint8List(0),
        );
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to prepare share card');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _shareNow() async {
    try {
      if (_assets == null) return;
      final clip = _assets!.clip;
      // Capture composed image if preset canvas is enabled; else fallback to image bytes if available
      Uint8List bytes;
      if (_usePresetCanvas) {
        final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          bytes = byteData?.buffer.asUint8List() ?? Uint8List(0);
        } else {
          bytes = _assets!.imageBytes;
        }
      } else {
        bytes = _assets!.imageBytes;
      }

      if (bytes.isEmpty) {
        await Share.share(clip, subject: _title.isNotEmpty ? _title : 'Story clip');
        return;
      }
      final xfile = XFile.fromData(bytes, name: 'story_share.png', mimeType: 'image/png');
      await Share.shareXFiles([xfile], text: clip, subject: _title.isNotEmpty ? _title : 'Story clip');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to open share sheet');
    }
  }

  Future<void> _copyClip() async {
    try {
      final clip = _assets?.clip ?? '';
      await Clipboard.setData(ClipboardData(text: clip));
      Fluttertoast.showToast(msg: 'Clip copied');
    } catch (_) {}
  }

  // Note: Saving image to gallery is platform-specific; consider adding an image saver plugin if needed.

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Story'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isGenerating
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 2.h),
                  Text('Crafting your share card...', style: theme.textTheme.bodyMedium),
                ],
              ),
            )
          : _assets == null
              ? Center(
                  child: Text('Nothing to share yet', style: theme.textTheme.bodyMedium),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Preset selector
                      Row(
                        children: [
                          Switch(
                            value: _usePresetCanvas,
                            onChanged: (v) => setState(() => _usePresetCanvas = v),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _preset,
                              isExpanded: true,
                              onChanged: _usePresetCanvas
                                  ? (v) => setState(() => _preset = v!)
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 'IG Portrait (1080x1350)',
                                  child: Text('IG Portrait (1080x1350)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Square (1080x1080)',
                                  child: Text('Square (1080x1080)'),
                                ),
                                DropdownMenuItem(
                                  value: 'X Landscape (1600x900)',
                                  child: Text('X Landscape (1600x900)'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      AspectRatio(
                        aspectRatio: _aspectRatioForPreset(_preset),
                        child: RepaintBoundary(
                          key: _captureKey,
                          child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Static starry sky background (no AI image)
                            Image.asset(
                              'assets/images/background.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackBg(),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_title.isNotEmpty)
                                    Text(
                                      _title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          const Shadow(color: Colors.black54, blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    _assets!.clip,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                      shadows: [
                                        const Shadow(color: Colors.black54, blurRadius: 6),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton.icon(
                        onPressed: _shareNow,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                      SizedBox(height: 1.h),
                      TextButton.icon(
                        onPressed: _copyClip,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Clip'),
                      ),
                    ],
                  ),
                ),
    );
  }

  double _aspectRatioForPreset(String p) {
    switch (p) {
      case 'IG Portrait (1080x1350)':
        return 1080 / 1350;
      case 'X Landscape (1600x900)':
        return 1600 / 900;
      case 'Square (1080x1080)':
      default:
        return 1.0;
    }
  }

  Widget _fallbackBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F2937),
            Color(0xFF111827),
          ],
        ),
      ),
    );
  }
}
