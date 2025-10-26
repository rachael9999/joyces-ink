import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../services/payment_service.dart';

class PaymentFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressLine1Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipCodeController;
  final SubscriptionPlan selectedPlan;
  final bool isProcessing;
  final String? message;
  final String? errorMessage;
  final VoidCallback onPayment;

  const PaymentFormWidget({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressLine1Controller,
    required this.cityController,
    required this.stateController,
    required this.zipCodeController,
    required this.selectedPlan,
    required this.isProcessing,
    this.message,
    this.errorMessage,
    required this.onPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected plan summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPlan.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedPlan.billingIntervalDisplay,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      selectedPlan.formattedPrice,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Billing Information
          Text(
            'Billing Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          _buildTextField(nameController, 'Full Name', true),
          _buildTextField(emailController, 'Email', true),
          _buildTextField(phoneController, 'Phone (Optional)', false),
          _buildTextField(addressLine1Controller, 'Address Line 1', true),

          Row(
            children: [
              Expanded(
                child: _buildTextField(cityController, 'City', true),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(stateController, 'State', true),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(zipCodeController, 'ZIP Code', true),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Payment Information
          Text(
            'Payment Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // CardField for payment input
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: stripe.CardField(
              onCardChanged: (card) {
                // Card validation handled by Stripe
              },
              decoration: InputDecoration(
                labelText: 'Card Information',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: InputBorder.none,
                helperText: kIsWeb
                    ? 'Enter your card details (Web CardField)'
                    : 'Enter your card details',
                helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Test card information (debug mode only)
          if (kDebugMode)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Cards for Development:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text('✅ Success: 4242 4242 4242 4242',
                      style: TextStyle(fontSize: 11)),
                  Text('❌ Declined: 4000 0000 0000 9995',
                      style: TextStyle(fontSize: 11)),
                  Text('🔒 3D Secure: 4000 0000 0000 3220',
                      style: TextStyle(fontSize: 11)),
                  Text('💳 Use any future expiration date and any CVC',
                      style:
                          TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          SizedBox(height: 20),

          // Messages
          if (message != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(message!,
                        style: TextStyle(color: Colors.green[800])),
                  ),
                ],
              ),
            ),

          if (errorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(errorMessage!,
                        style: TextStyle(color: Colors.red[800])),
                  ),
                ],
              ),
            ),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(message ?? 'Processing...'),
                      ],
                    )
                  : Text(
                      'Subscribe to ${selectedPlan.name} - ${selectedPlan.formattedPrice}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          SizedBox(height: 16),

          // Security notice
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.grey[600], size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your payment information is secure and encrypted by Stripe. We never store your card details.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool required) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
