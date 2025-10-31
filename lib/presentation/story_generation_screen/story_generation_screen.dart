import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_service.dart';
import '../../services/journal_service.dart';
import '../../services/story_service.dart';
// import '../../services/share_service.dart'; // No longer auto-creating share cards on save
import './widgets/advanced_options_widget.dart';
import './widgets/genre_selection_widget.dart';
import './widgets/journal_entry_preview_widget.dart';
import './widgets/story_generation_button_widget.dart';
import './widgets/story_preview_widget.dart';

class StoryGenerationScreen extends StatefulWidget {
  const StoryGenerationScreen({Key? key}) : super(key: key);

  @override
  State<StoryGenerationScreen> createState() => _StoryGenerationScreenState();
}

class _StoryGenerationScreenState extends State<StoryGenerationScreen>
    with TickerProviderStateMixin {
  // Services
  late final GeminiService _geminiService;
  late final GeminiClient _geminiClient;
  late final GeminiRequestManager _requestManager;

  // Generation states
  bool _isGenerating = false;
  bool _showProgress = false;
  bool _showStoryPreview = false;

  // Generation progress (removed unused fields)

  // User selections
  String? _selectedGenre;
  String? _selectedTemplate;
  Map<String, dynamic> _advancedOptions = {
    'length': 'Medium',
    'perspective': 'First Person',
    'writingStyle': 'Descriptive',
    'characterDevelopment': 0.5,
    'pacing': 0.6,
    'toneIntensity': 0.5,
    'creativity': 0.7,
    'targetAudience': 'All Ages',
    'endingStyle': 'Conclusive',
  };

  // Data
  Map<String, dynamic>? _selectedJournalEntry;
  Map<String, dynamic>? _generatedStory;

  // Animation controllers
  late AnimationController _progressAnimationController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadJournalEntry();

    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    _geminiService = GeminiService();
    _geminiClient = GeminiClient(
      _geminiService.dio,
      _geminiService.authApiKey,
      provider: _geminiService.providerName,
    );
    _requestManager = GeminiRequestManager();
  }

  Future<void> _loadJournalEntry() async {
    try {
      // Get the most recent journal entry or use passed argument
      final entries =
          await JournalService.instance.getJournalEntries(limit: 1);
      if (entries.isNotEmpty) {
        setState(() {
          _selectedJournalEntry = entries.first;
        });
      } else {
        // Use default mock data if no entries exist
        setState(() {
          _selectedJournalEntry = {
            'id': 'demo',
            'title': 'A Day of Unexpected Discoveries',
            'content':
                '''Today started like any other Tuesday, but it turned into something extraordinary. I was walking through the old part of town when I stumbled upon a small bookshop I'd never noticed before. The owner, an elderly woman with kind eyes, told me the most fascinating stories about the neighborhood's history. She mentioned a hidden garden behind the building that used to be a meeting place for local artists in the 1960s. I spent hours there, feeling inspired and connected to something bigger than myself. Sometimes the best adventures happen when you least expect them.''',
            'created_at': DateTime.now().toIso8601String(),
            'mood': 'Inspired',
            'tags': ['discovery', 'inspiration', 'community'],
          };
        });
      }
    } catch (error) {
      print('Error loading journal entry: $error');
      // Use mock data as fallback
      setState(() {
        _selectedJournalEntry = {
          'id': 'demo',
          'title': 'A Day of Unexpected Discoveries',
          'content':
              '''Today started like any other Tuesday, but it turned into something extraordinary. I was walking through the old part of town when I stumbled upon a small bookshop I'd never noticed before. The owner, an elderly woman with kind eyes, told me the most fascinating stories about the neighborhood's history. She mentioned a hidden garden behind the building that used to be a meeting place for local artists in the 1960s. I spent hours there, feeling inspired and connected to something bigger than myself. Sometimes the best adventures happen when you least expect them.''',
          'created_at': DateTime.now().toIso8601String(),
          'mood': 'Inspired',
          'tags': ['discovery', 'inspiration', 'community'],
        };
      });
    }
  }

  void _onGenreSelected(String genre) {
    setState(() {
      _selectedGenre = genre;
    });
    HapticFeedback.selectionClick();
  }

  void _onTemplateSelected(String? template) {
    setState(() {
      _selectedTemplate = template;
    });
    HapticFeedback.selectionClick();
  }

  void _onAdvancedOptionsChanged(Map<String, dynamic> options) {
    setState(() {
      _advancedOptions = options;
    });
  }

  Future<void> _generateStory() async {
    if (_selectedGenre == null || _selectedJournalEntry == null) return;

    setState(() {
      _isGenerating = true;
      _showProgress = true;
      _showStoryPreview = false;
  // reset internal progress in manager only
    });

    HapticFeedback.mediumImpact();

    try {
      final result = await _requestManager
          .startRequest<GeminiCompletion>((cancelToken, onProgress) async {
        return await _geminiClient.generateStoryFromJournal(
          journalTitle: _selectedJournalEntry!['title'] ?? 'Untitled Entry',
          journalContent: _selectedJournalEntry!['content'] ?? '',
          genre: _selectedGenre!,
          options: _advancedOptions,
          cancelToken: cancelToken,
          onProgressUpdate: onProgress,
        );
      });

      // Parse structured story between **title** and **end**, and extract H1 title
      final parsed = _extractStructuredStory(result.text);
      final parsedTitle = parsed['title'];
      final storyContent = parsed['body'] ?? '';
      final wordCount = storyContent.split(' ').length;
      final readTime = (wordCount / 200).ceil();

      _generatedStory = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': (parsedTitle != null && parsedTitle.isNotEmpty)
            ? parsedTitle
            : _generateStoryTitle(_selectedGenre!),
        'content': storyContent,
        'genre': _selectedGenre,
        'wordCount': wordCount,
        'readTime': readTime,
        'createdAt': DateTime.now().toIso8601String(),
        'options': _advancedOptions,
        'originalEntry': _selectedJournalEntry,
      };

      setState(() {
        _isGenerating = false;
        _showProgress = false;
        _showStoryPreview = true;
      });

      HapticFeedback.heavyImpact();
      _showSuccessToast();
    } on GeminiException catch (e) {
      setState(() {
        _isGenerating = false;
        _showProgress = false;
      });

      _showErrorToast('Story generation failed: ${e.message}');
    } catch (error) {
      setState(() {
        _isGenerating = false;
        _showProgress = false;
      });

      _showErrorToast('An unexpected error occurred. Please try again.');
    }
  }

  // Extract content between **title** and **end**, parse first Markdown H1 as title.
  Map<String, String> _extractStructuredStory(String raw) {
    final text = raw.trim();
    final titleMarker = RegExp(r"\*\*\s*title\s*\*\*", caseSensitive: false);
    final endMarker = RegExp(r"\*\*\s*end\s*\*\*", caseSensitive: false);

    final start = titleMarker.firstMatch(text);
    if (start == null) {
      // No marker: return whole text as body
      return {'title': '', 'body': text};
    }
    final startIndex = start.end;
    final rest = text.substring(startIndex);
    final end = endMarker.firstMatch(rest);
    String contentSegment = (end != null)
        ? rest.substring(0, end.start)
        : rest; // tolerate missing **end**

    // Sanitize: remove stray markers/echoes like **Untitled Entry**
    List<String> lines = contentSegment.trim().split(RegExp(r'\r?\n'));
    // Drop leading empty lines
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines = lines.sublist(1);
    }
    // Drop a leading bold/plain "Untitled Entry" line if present
    final untitledPattern = RegExp(r'^(\*\*|__)?\s*Untitled\s+Entry\s*(\*\*|__)?$', caseSensitive: false);
    if (lines.isNotEmpty && untitledPattern.hasMatch(lines.first.trim())) {
      lines = lines.sublist(1);
    }

    // Also remove any trailing plain/bold 'end' tokens if model printed without markers
    final plainEndPattern = RegExp(r'^(\*\*|__)?\s*end\s*(\*\*|__)?$', caseSensitive: false);
    while (lines.isNotEmpty && plainEndPattern.hasMatch(lines.last.trim())) {
      lines.removeLast();
    }

    contentSegment = lines.join('\n');

    // Parse first line as H1 title if present
    lines = contentSegment.trim().split(RegExp(r'\r?\n'));
    String parsedTitle = '';
    String body = contentSegment.trim();
    if (lines.isNotEmpty) {
      final h1 = RegExp(r'^\s*#\s+(.+)$');
      final m = h1.firstMatch(lines[0]);
      if (m != null) {
        parsedTitle = (m.group(1) ?? '').trim();
        body = lines.skip(1).join('\n').trim();
      }
    }
    return {'title': parsedTitle, 'body': body};
  }

  String _generateStoryTitle(String genre) {
    final baseTitle =
        _selectedJournalEntry?['title'] ?? 'An Unexpected Journey';

    switch (genre.toLowerCase()) {
      case 'horror':
        return 'The Dark Side of ${baseTitle.replaceAll('A Day of ', '')}';
      case 'romance':
        return 'Love Found in ${baseTitle.replaceAll('A Day of ', '')}';
      case 'comedy':
        return 'The Hilarious Tale of ${baseTitle.replaceAll('A Day of ', '')}';
      case 'mystery':
        return 'The Mystery of ${baseTitle.replaceAll('A Day of ', '')}';
      case 'drama':
        return 'Echoes of ${baseTitle.replaceAll('A Day of ', '')}';
      case 'chick-flick':
        return 'Finding Magic in ${baseTitle.replaceAll('A Day of ', '')}';
      default:
        return baseTitle;
    }
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "Your ${_selectedGenre?.toLowerCase()} story is ready! 🎉",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryLight,
      textColor: AppTheme.onPrimaryLight,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _onEditJournalEntry() {
    Navigator.pushNamed(context, AppRoutes.journalEntryCreation);
  }

  void _onRegenerateStory() {
    _generateStory();
  }

  void _onEditStory() {
    Fluttertoast.showToast(
      msg: "Story editing feature coming soon!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _onSaveStory() async {
    if (_generatedStory == null) return;

    try {
      final saved = await StoryService.instance.createGeneratedStory(
        journalEntryId: _selectedJournalEntry?['id']?.toString(),
        title: _generatedStory!['title'],
        content: _generatedStory!['content'],
        genre: _generatedStory!['genre'],
      );

      // Do not auto-create share card or assets on save

      Fluttertoast.showToast(
        msg: "Story saved to your library! 📚",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.primaryLight,
        textColor: AppTheme.onPrimaryLight,
      );

      // Open Share screen pre-populated
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.storyShareScreen,
          arguments: {
            'title': saved['title'] ?? _generatedStory!['title'],
            'content': saved['content'] ?? _generatedStory!['content'],
            'genre': saved['genre'] ?? _generatedStory!['genre'],
            'storyId': saved['id'].toString(),
          },
        );
      }
    } catch (error) {
      // Surface a concise error to help diagnose (enum/UUID/RLS issues)
      final msg = error.toString();
      final shortMsg = msg.length > 160 ? msg.substring(0, 160) + '…' : msg;
      _showErrorToast('Failed to save story: $shortMsg');
    }
  }

  void _onShareStory() {
    if (_generatedStory == null) return;
    final story = _generatedStory!;
    Navigator.pushNamed(
      context,
      AppRoutes.storyShareScreen,
      arguments: {
        'title': story['title'] ?? '',
        'content': story['content'] ?? '',
        'genre': story['genre'] ?? '',
      },
    );
  }

  void _onExportStory() {
    if (_generatedStory != null) {
      Fluttertoast.showToast(
        msg: "Story exported successfully! 📄",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onCancelGeneration() {
    _requestManager.cancelRequest();
    setState(() {
      _isGenerating = false;
      _showProgress = false;
  // reset internal progress in manager only
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Story Generation',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: "Powered by Gemini AI - Advanced Story Generation",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            icon: CustomIconWidget(
              iconName: 'auto_awesome',
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journal Entry Preview
              if (!_showProgress &&
                  !_showStoryPreview &&
                  _selectedJournalEntry != null)
                JournalEntryPreviewWidget(
                  journalEntry: _selectedJournalEntry!,
                  onEdit: _onEditJournalEntry,
                ),

              // Genre Selection
              if (!_showProgress && !_showStoryPreview)
                GenreSelectionWidget(
                  selectedGenre: _selectedGenre,
                  onGenreSelected: _onGenreSelected,
                ),

              // Advanced Options
              if (!_showProgress && !_showStoryPreview)
                AdvancedOptionsWidget(
                  options: _advancedOptions,
                  onOptionsChanged: _onAdvancedOptionsChanged,
                  selectedTemplate: _selectedTemplate,
                  onTemplateSelected: _onTemplateSelected,
                ),

              // Generation Button
              if (!_showProgress && !_showStoryPreview)
                StoryGenerationButtonWidget(
                  isGenerating: _isGenerating,
                  selectedGenre: _selectedGenre,
                  onGenerate: _generateStory,
                ),

              // Generation Progress
              if (_showProgress && _selectedGenre != null)
                Container(
                  margin: EdgeInsets.all(4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.primaryLight,
                            size: 24,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Generating ${_selectedGenre!} Story with Gemini AI...',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_isGenerating)
                            IconButton(
                              onPressed: _onCancelGeneration,
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 3.w),
                      Text(
                        _requestManager.processingStage,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 2.w),
                      LinearProgressIndicator(
                        value: _requestManager.processingProgress / 100,
                        backgroundColor: AppTheme.primaryLight.withAlpha(51),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLight),
                      ),
                      SizedBox(height: 2.w),
                      Text(
                        '${_requestManager.processingProgress.round()}% Complete',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

              // Story Preview
              if (_showStoryPreview && _generatedStory != null)
                StoryPreviewWidget(
                  generatedStory: _generatedStory!,
                  onRegenerate: _onRegenerateStory,
                  onEdit: _onEditStory,
                  onSave: _onSaveStory,
                  onShare: _onShareStory,
                  onExport: _onExportStory,
                ),

              // Bottom spacing
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}