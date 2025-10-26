import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TwoFactorSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const TwoFactorSectionWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<TwoFactorSectionWidget> createState() => _TwoFactorSectionWidgetState();
}

class _TwoFactorSectionWidgetState extends State<TwoFactorSectionWidget> {
  bool _isTwoFactorEnabled = false;
  String _selectedMethod = 'authenticator';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _toggleTwoFactor(bool value) {
    if (value) {
      _showSetupDialog();
    } else {
      _showDisableDialog();
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Setup Two-Factor Authentication',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your preferred 2FA method:',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 2.h),

                // Method Selection
                RadioListTile<String>(
                  title: const Text('Authenticator App'),
                  subtitle: const Text('Google Authenticator, Authy, etc.'),
                  value: 'authenticator',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedMethod = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text('SMS'),
                  subtitle: const Text('Text messages to your phone'),
                  value: 'sms',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedMethod = value!;
                    });
                  },
                ),

                if (_selectedMethod == 'sms') ...[
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+1 (555) 123-4567',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],

                if (_selectedMethod == 'authenticator') ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.qr_code,
                            size: 15.w,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'QR Code',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Scan with your authenticator app',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 2.h),

                TextFormField(
                  controller: _verificationCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: Icon(Icons.security),
                    hintText: '123456',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isTwoFactorEnabled = true;
                });
                widget.onChanged();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Two-factor authentication enabled'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Disable Two-Factor Authentication',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 12.w,
              color: Colors.orange,
            ),
            SizedBox(height: 2.h),
            Text(
              'Disabling 2FA will make your account less secure. Are you sure you want to continue?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
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
                _isTwoFactorEnabled = false;
              });
              widget.onChanged();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication disabled'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _showRecoveryCodes() {
    final recoveryCodes = [
      '8H9K-2L3M-4N5P',
      'Q6R7-S8T9-U0V1',
      'W2X3-Y4Z5-A6B7',
      'C8D9-E0F1-G2H3',
      'I4J5-K6L7-M8N9',
      'O0P1-Q2R3-S4T5',
      'U6V7-W8X9-Y0Z1',
      'A2B3-C4D5-E6F7',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recovery Codes',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.orange.shade700,
                      size: 4.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Save these codes in a secure place. Each code can only be used once.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: recoveryCodes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        child: Text(
                          '${index + 1}. ${recoveryCodes[index]}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              // Copy to clipboard functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recovery codes copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Copy Codes'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
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
                  'Two-Factor Authentication',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.security,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Text(
              'Add an extra layer of security to your account',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 3.h),

            // 2FA Toggle
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isTwoFactorEnabled ? Icons.shield_outlined : Icons.shield,
                    color: _isTwoFactorEnabled ? Colors.green : Colors.grey,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _isTwoFactorEnabled
                              ? 'Enabled via ${_selectedMethod == 'authenticator' ? 'Authenticator App' : 'SMS'}'
                              : 'Disabled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: _isTwoFactorEnabled
                                ? Colors.green
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isTwoFactorEnabled,
                    onChanged: _toggleTwoFactor,
                  ),
                ],
              ),
            ),

            if (_isTwoFactorEnabled) ...[
              SizedBox(height: 2.h),

              // Recovery Codes
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showRecoveryCodes,
                  icon: const Icon(Icons.key_outlined),
                  label: const Text('View Recovery Codes'),
                ),
              ),
            ],

            if (!_isTwoFactorEnabled) ...[
              SizedBox(height: 2.h),

              // Security Recommendation
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
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 4.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Enable 2FA to significantly improve your account security',
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
          ],
        ),
      ),
    );
  }
}
