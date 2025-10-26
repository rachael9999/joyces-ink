import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const SubscriptionPlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.isCurrentPlan,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCurrentPlan ? null : onSelect,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isCurrentPlan
                    ? Colors.green
                    : Colors.grey[300]!,
            width: isSelected || isCurrentPlan ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withAlpha(13)
              : isCurrentPlan
                  ? Colors.green.withAlpha(13)
                  : Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and current plan badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isCurrentPlan ? Colors.green[700] : null,
                          ),
                        ),
                        Text(
                          plan.billingIntervalDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentPlan)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Current Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isSelected && !isCurrentPlan)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                ],
              ),

              SizedBox(height: 12),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${plan.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isCurrentPlan ? Colors.green[700] : null,
                    ),
                  ),
                  Text(
                    '.${((plan.price % 1) * 100).toInt().toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '/${plan.billingInterval == 'year' ? 'year' : 'month'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Savings for yearly plan
              if (plan.billingInterval == 'year')
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Save \$20 per year',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Description
              Text(
                plan.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              SizedBox(height: 16),

              // Features list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: isCurrentPlan
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Call to action
              if (!isCurrentPlan)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isSelected ? 'Selected' : 'Select Plan',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
