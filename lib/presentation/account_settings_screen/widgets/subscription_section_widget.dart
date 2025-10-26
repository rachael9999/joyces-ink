import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SubscriptionSectionWidget extends StatefulWidget {
  const SubscriptionSectionWidget({super.key});

  @override
  State<SubscriptionSectionWidget> createState() =>
      _SubscriptionSectionWidgetState();
}

class _SubscriptionSectionWidgetState extends State<SubscriptionSectionWidget> {
  final String _currentPlan = 'Free';
  final bool _isPremium = false;
  final DateTime _renewalDate = DateTime(2024, 11, 22);

  void _upgradeToPremium() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Upgrade to Premium',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium features include:',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            _buildFeature('Unlimited story generation'),
            _buildFeature('Advanced AI creativity settings'),
            _buildFeature('Priority customer support'),
            _buildFeature('Export to multiple formats'),
            _buildFeature('No ads'),
            SizedBox(height: 2.h),
            Text(
              '\$9.99/month',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
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
              // Implement upgrade logic
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 4.w,
            color: Colors.green,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewBillingHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Billing History',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 40.h,
          child: _isPremium
              ? ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.receipt,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Premium Subscription'),
                      subtitle: Text('Oct ${22 - index}, 2024'),
                      trailing: Text('\$9.99'),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 12.w,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No billing history',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'You\'re on the free plan',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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
  }

  void _cancelSubscription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Subscription',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We\'re sorry to see you go! Your premium features will remain active until your next billing date.',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              'What can we do to improve?',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Premium'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement cancellation logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Subscription will be cancelled at the end of billing period'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Subscription'),
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
                  'Subscription',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.star_outline,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Current Plan
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPremium
                      ? [Colors.amber.shade100, Colors.amber.shade50]
                      : [theme.colorScheme.surface, theme.colorScheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPremium ? Colors.amber : theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Plan: $_currentPlan',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (_isPremium) ...[
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade700,
                          size: 4.w,
                        ),
                      ],
                    ],
                  ),
                  if (_isPremium) ...[
                    SizedBox(height: 1.h),
                    Text(
                      'Renews on ${_renewalDate.day}/${_renewalDate.month}/${_renewalDate.year}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Payment Method: •••• •••• •••• 1234',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 1.h),
                    Text(
                      'Limited story generations • Basic features',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Action Buttons
            if (!_isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _upgradeToPremium,
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Upgrade to Premium'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelSubscription,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _upgradeToPremium,
                      icon: const Icon(Icons.upgrade),
                      label: const Text('Manage'),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 2.h),

            // Billing History
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _viewBillingHistory,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Billing History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
