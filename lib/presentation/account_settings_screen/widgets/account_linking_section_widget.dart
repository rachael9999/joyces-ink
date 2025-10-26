import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AccountLinkingSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const AccountLinkingSectionWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<AccountLinkingSectionWidget> createState() =>
      _AccountLinkingSectionWidgetState();
}

class _AccountLinkingSectionWidgetState
    extends State<AccountLinkingSectionWidget> {
  bool _isGoogleLinked = true;
  bool _isAppleLinked = false;
  bool _isFacebookLinked = false;

  void _linkAccount(String provider) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Linking account...'),
          ],
        ),
      ),
    );

    // Simulate linking process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop();

      setState(() {
        switch (provider.toLowerCase()) {
          case 'google':
            _isGoogleLinked = true;
            break;
          case 'apple':
            _isAppleLinked = true;
            break;
          case 'facebook':
            _isFacebookLinked = true;
            break;
        }
      });

      widget.onChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$provider account linked successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _unlinkAccount(String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unlink $provider Account',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to unlink your $provider account? You won\'t be able to sign in using $provider anymore.',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                switch (provider.toLowerCase()) {
                  case 'google':
                    _isGoogleLinked = false;
                    break;
                  case 'apple':
                    _isAppleLinked = false;
                    break;
                  case 'facebook':
                    _isFacebookLinked = false;
                    break;
                }
              });

              widget.onChanged();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$provider account unlinked'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountLinkTile({
    required String provider,
    required IconData icon,
    required bool isLinked,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 5.w,
          ),
        ),
        title: Text(
          provider,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          isLinked ? 'Connected' : 'Not connected',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: isLinked
                ? Colors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isLinked
            ? IconButton(
                onPressed: () => _unlinkAccount(provider),
                icon: Icon(
                  Icons.link_off,
                  color: Colors.red,
                  size: 5.w,
                ),
                tooltip: 'Unlink $provider',
              )
            : OutlinedButton(
                onPressed: () => _linkAccount(provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                ),
                child: const Text('Link'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  'Connected Accounts',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.link,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Text(
              'Link your social accounts for easier sign-in',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 3.h),

            // Google Account
            _buildAccountLinkTile(
              provider: 'Google',
              icon: Icons.g_mobiledata,
              isLinked: _isGoogleLinked,
              color: Colors.red,
            ),

            // Apple Account
            _buildAccountLinkTile(
              provider: 'Apple',
              icon: Icons.apple,
              isLinked: _isAppleLinked,
              color: Colors.black,
            ),

            // Facebook Account
            _buildAccountLinkTile(
              provider: 'Facebook',
              icon: Icons.facebook,
              isLinked: _isFacebookLinked,
              color: Colors.blue,
            ),

            // Info Banner
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Linking accounts provides convenient sign-in options and helps secure your account',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
