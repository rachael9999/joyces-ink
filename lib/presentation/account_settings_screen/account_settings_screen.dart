import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_deletion_section_widget.dart';
import './widgets/account_linking_section_widget.dart';
import './widgets/password_section_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/subscription_section_widget.dart';
import './widgets/two_factor_section_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _hasUnsavedChanges = false;

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _saveChanges() {
    // Save logic here
    setState(() {
      _hasUnsavedChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account settings saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Unsaved Changes',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'You have unsaved changes. Do you want to save them before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                _saveChanges();
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            'Account Settings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _saveChanges,
                child: Text(
                  'Save',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Profile Section
              ProfileSectionWidget(
                onChanged: _markAsChanged,
              ),

              SizedBox(height: 3.h),

              // Password Section
              PasswordSectionWidget(
                onChanged: _markAsChanged,
              ),

              SizedBox(height: 3.h),

              // Subscription Section
              const SubscriptionSectionWidget(),

              SizedBox(height: 3.h),

              // Account Linking Section
              AccountLinkingSectionWidget(
                onChanged: _markAsChanged,
              ),

              SizedBox(height: 3.h),

              // Two Factor Authentication
              TwoFactorSectionWidget(
                onChanged: _markAsChanged,
              ),

              SizedBox(height: 3.h),

              // Account Deletion
              const AccountDeletionSectionWidget(),

              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }
}
