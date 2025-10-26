import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AccountDeletionSectionWidget extends StatefulWidget {
  const AccountDeletionSectionWidget({super.key});

  @override
  State<AccountDeletionSectionWidget> createState() =>
      _AccountDeletionSectionWidgetState();
}

class _AccountDeletionSectionWidgetState
    extends State<AccountDeletionSectionWidget> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _startDeletionProcess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 15.w,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              'This action cannot be undone',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Deleting your account will permanently remove all your stories, journal entries, and personal data from joycesink.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeletionSteps();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDeletionSteps() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Account Deletion Process',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What will happen:',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Data deletion information
                  _buildDeletionStep(
                    icon: Icons.auto_stories_outlined,
                    title: 'Stories & Journal Entries',
                    description:
                        'All your creative content will be permanently deleted',
                    isDestructive: true,
                  ),

                  _buildDeletionStep(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    description:
                        'Profile, preferences, and account data will be removed',
                    isDestructive: true,
                  ),

                  _buildDeletionStep(
                    icon: Icons.payment_outlined,
                    title: 'Subscription & Billing',
                    description: 'Active subscriptions will be cancelled',
                    isDestructive: true,
                  ),

                  _buildDeletionStep(
                    icon: Icons.backup_outlined,
                    title: 'Data Backup',
                    description:
                        'Some data may be retained for 30 days for legal compliance',
                    isDestructive: false,
                  ),

                  SizedBox(height: 3.h),

                  // Password confirmation
                  Text(
                    'Confirm your identity:',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  TextFormField(
                    controller: _confirmationController,
                    decoration: const InputDecoration(
                      labelText: 'Type "DELETE" to confirm',
                      prefixIcon: Icon(Icons.warning_outlined),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Final warning
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 4.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'This action is irreversible. Once deleted, your account and data cannot be recovered.',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.red.shade700,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _passwordController.text.isNotEmpty &&
                      _confirmationController.text.toUpperCase() == 'DELETE'
                  ? () {
                      Navigator.of(context).pop();
                      _confirmFinalDeletion();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionStep({
    required IconData icon,
    required String title,
    required String description,
    required bool isDestructive,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 5.w,
            color: isDestructive ? Colors.red.shade600 : Colors.orange.shade600,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? Colors.red.shade700
                        : Colors.orange.shade700,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmFinalDeletion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Final Confirmation',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever_outlined,
              size: 15.w,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              'Last chance to change your mind',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your account and all associated data will be permanently deleted. This action cannot be undone.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to settings
            },
            child: const Text('Keep Account'),
          ),
          TextButton(
            onPressed: () {
              // Simulate account deletion
              Navigator.of(context).pop();
              _showDeletionProgress();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showDeletionProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 3.h),
            Text(
              'Deleting your account...',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'This may take a few moments',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate deletion process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account deletion initiated. You will be signed out shortly.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withAlpha(51),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danger Zone',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                Icon(
                  Icons.dangerous_outlined,
                  size: 5.w,
                  color: Colors.red.shade600,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Text(
              'Permanently delete your joycesink account and all associated data',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 3.h),

            // Warning Container
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.red.shade700,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Account Deletion',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Once you delete your account, there is no going back. Please be certain.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _startDeletionProcess,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete Account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Data Retention Policy Link
            Center(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Data Retention Policy',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Text(
                          'When you delete your account:\n\n'
                          '• Personal data is immediately removed from our active systems\n'
                          '• Some data may be retained in backups for up to 30 days for legal compliance\n'
                          '• Analytics data is anonymized and may be retained for business purposes\n'
                          '• All personally identifiable information is permanently deleted\n\n'
                          'For more details, please review our Privacy Policy.',
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'View Data Retention Policy',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
