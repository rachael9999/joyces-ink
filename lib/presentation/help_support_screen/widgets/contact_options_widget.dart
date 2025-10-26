import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactOptionsWidget extends StatelessWidget {
  const ContactOptionsWidget({super.key});

  void _openInAppMessaging(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.message,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Support Chat',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Chat Interface Simulation
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Support Agent Introduction
                      _buildChatMessage(
                        context,
                        isUser: false,
                        message:
                            'Hi! I\'m here to help you with joycesink. What can I assist you with today?',
                        timestamp: 'Just now',
                        agentName: 'Sarah',
                      ),

                      // Quick Action Buttons
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickActionChip(context, 'Account Issue'),
                            _buildQuickActionChip(context, 'Bug Report'),
                            _buildQuickActionChip(context, 'Feature Question'),
                            _buildQuickActionChip(context, 'Billing Support'),
                            _buildQuickActionChip(context, 'Technical Help'),
                            _buildQuickActionChip(context, 'Other'),
                          ],
                        ),
                      ),

                      // Status Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Support team is online • Average response time: 2 minutes',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Space for input field
                    ],
                  ),
                ),
              ),

              // Message Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: GoogleFonts.inter(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "Message sent to support team!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(
    BuildContext context, {
    required bool isUser,
    required String message,
    required String timestamp,
    String? agentName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                agentName?.substring(0, 1) ?? 'S',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser && agentName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      agentName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timestamp,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(BuildContext context, String label) {
    return ActionChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Starting conversation about $label",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      },
    );
  }

  void _sendEmail(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Opening email app...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showLiveChatUnavailable(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live Chat Unavailable',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our live chat support is currently offline.',
              style: GoogleFonts.inter(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(77),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Chat Hours:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monday - Friday: 9:00 AM - 6:00 PM EST\n'
                    'Saturday: 10:00 AM - 4:00 PM EST\n'
                    'Sunday: Closed',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can still reach us via email or in-app messaging for non-urgent issues.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmail(context);
            },
            child: Text(
              'Send Email',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLiveChatOnline =
        DateTime.now().hour >= 9 && DateTime.now().hour < 18;

    final List<Map<String, dynamic>> contactMethods = [
      {
        'title': 'In-App Messaging',
        'description': 'Send us a message directly within the app',
        'icon': Icons.message,
        'color': Theme.of(context).colorScheme.primary,
        'status': 'Available 24/7',
        'responseTime': 'Usually within 2-4 hours',
        'onTap': () => _openInAppMessaging(context),
      },
      {
        'title': 'Email Support',
        'description': 'Get help via email for detailed inquiries',
        'icon': Icons.email,
        'color': Colors.blue,
        'status': 'support@joycesink.com',
        'responseTime': 'Usually within 24 hours',
        'onTap': () => _sendEmail(context),
      },
      {
        'title': 'Live Chat',
        'description': 'Real-time chat with our support team',
        'icon': Icons.chat_bubble,
        'color': isLiveChatOnline ? Colors.green : Colors.orange,
        'status': isLiveChatOnline ? 'Online now' : 'Currently offline',
        'responseTime':
            isLiveChatOnline ? 'Instant responses' : 'See availability hours',
        'onTap': () => isLiveChatOnline
            ? _openInAppMessaging(context)
            : _showLiveChatUnavailable(context),
      },
    ];

    return Column(
      children: [
        // Contact Methods
        ...contactMethods.map((method) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: method['color'].withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'],
                            color: method['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'],
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method['description'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Status and Response Time
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: method['color'].withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: method['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    method['status'],
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: method['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          method['responseTime'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: method['onTap'],
                        style: ElevatedButton.styleFrom(
                          backgroundColor: method['color'],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Contact via ${method['title']}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        // Emergency Contact Information
        Card(
          color: Theme.of(context).colorScheme.errorContainer.withAlpha(26),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Urgent Issues',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'For critical issues that require immediate attention (data loss, security concerns, payment problems), please use in-app messaging and mark your message as "Urgent".',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _openInAppMessaging(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.priority_high, size: 18),
                  label: Text(
                    'Report Urgent Issue',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
