import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const ProfileSectionWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  final TextEditingController _displayNameController = TextEditingController(
    text: 'Creative Writer',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'writer@joycesink',
  );

  bool _isEmailVerified = true;
  String _profileImageUrl =
      'https://images.unsplash.com/photo-1494790108755-2616b612b5c5?w=150&h=150&fit=crop&crop=face';

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // In a real app, upload to storage and get URL
      setState(() {
        _profileImageUrl = image.path;
      });
      widget.onChanged();
    }
  }

  void _resendVerification() {
    // Resend email verification logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent'),
        behavior: SnackBarBehavior.floating,
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
            Text(
              'Profile Information',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 3.h),

            // Profile Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 8.w,
                    backgroundImage: _profileImageUrl.startsWith('http')
                        ? NetworkImage(_profileImageUrl)
                        : const NetworkImage(
                            'https://images.unsplash.com/photo-1494790108755-2616b612b5c5?w=150&h=150&fit=crop&crop=face'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeProfileImage,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 4.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Display Name Field
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => widget.onChanged(),
            ),

            SizedBox(height: 3.h),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _isEmailVerified
                    ? Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 5.w,
                      )
                    : TextButton(
                        onPressed: _resendVerification,
                        child: Text(
                          'Verify',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
              onChanged: (_) => widget.onChanged(),
              readOnly: true, // Email changes require special verification
            ),

            SizedBox(height: 2.h),

            // Account Creation Date
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 4.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member Since',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'October 22, 2024',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!_isEmailVerified) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.amber.shade700,
                      size: 4.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Please verify your email address to secure your account',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
