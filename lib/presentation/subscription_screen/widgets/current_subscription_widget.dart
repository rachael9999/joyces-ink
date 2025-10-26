import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';

class CurrentSubscriptionWidget extends StatelessWidget {
  final UserSubscription subscription;
  final VoidCallback? onCancel;

  const CurrentSubscriptionWidget({
    Key? key,
    required this.subscription,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: subscription.isActive
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: subscription.isActive
                ? Colors.green.withAlpha(77)
                : Colors.orange.withAlpha(77),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Subscription',
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subscription.subscriptionPlan?.name ?? 'Premium Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subscription.statusDisplay,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                subscription.isActive
                    ? Icons.verified
                    : subscription.isCanceled
                        ? Icons.cancel_outlined
                        : Icons.warning_outlined,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Subscription details
          _buildDetailRow(
            'Plan',
            subscription.subscriptionPlan?.name ?? 'Premium',
          ),
          _buildDetailRow(
            'Billing',
            subscription.subscriptionPlan?.billingIntervalDisplay ?? 'Monthly',
          ),
          if (subscription.currentPeriodEnd != null)
            _buildDetailRow(
              subscription.isActive ? 'Next Billing' : 'Expires',
              _formatDate(subscription.currentPeriodEnd!),
            ),
          if (subscription.canceledAt != null && subscription.isCanceled)
            _buildDetailRow(
              'Canceled On',
              _formatDate(subscription.canceledAt!),
            ),

          // Action buttons
          SizedBox(height: 20),
          Row(
            children: [
              if (subscription.isActive && onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Cancel Subscription'),
                  ),
                ),
              if (!subscription.isActive)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to reactivation or new subscription
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: subscription.isActive
                          ? Colors.green[600]
                          : Colors.orange[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Reactivate'),
                  ),
                ),
            ],
          ),

          // Premium features reminder
          if (subscription.isActive) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have access to all premium features!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Grace period warning for past due
          if (subscription.isPastDue) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment is past due. Please update your payment method to continue enjoying premium features.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
