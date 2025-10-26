import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/app_info_widget.dart';
import './widgets/community_section_widget.dart';
import './widgets/contact_options_widget.dart';
import './widgets/faq_section_widget.dart';
import './widgets/feedback_section_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/search_help_widget.dart';
import './widgets/troubleshooting_widget.dart';
import './widgets/video_tutorials_widget.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).appBarTheme.foregroundColor,
            size: 20,
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search help articles...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 16,
                  ),
                ),
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              )
            : Text(
                'Help & Support',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Help Section
              if (_searchQuery.isNotEmpty) ...[
                SearchHelpWidget(searchQuery: _searchQuery),
                const SizedBox(height: 24),
              ],

              // Quick Actions Section
              if (_searchQuery.isEmpty) ...[
                Text(
                  'Quick Actions',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const QuickActionsWidget(),
                const SizedBox(height: 32),
              ],

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              FaqSectionWidget(searchQuery: _searchQuery),
              const SizedBox(height: 32),

              // Video Tutorials Section
              if (_searchQuery.isEmpty) ...[
                Text(
                  'Video Tutorials',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const VideoTutorialsWidget(),
                const SizedBox(height: 32),

                // Troubleshooting Guides
                Text(
                  'Troubleshooting Guides',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const TroubleshootingWidget(),
                const SizedBox(height: 32),

                // Community Section
                Text(
                  'Community',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const CommunitySectionWidget(),
                const SizedBox(height: 32),

                // App Information
                Text(
                  'App Information',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const AppInfoWidget(),
                const SizedBox(height: 32),

                // Feedback Section
                Text(
                  'Feedback',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const FeedbackSectionWidget(),
                const SizedBox(height: 32),

                // Contact Options
                Text(
                  'Contact Us',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                const ContactOptionsWidget(),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
