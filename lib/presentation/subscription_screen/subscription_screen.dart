import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import './widgets/current_subscription_widget.dart';
import './widgets/payment_form_widget.dart';
import './widgets/subscription_plan_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionPlan> _plans = [];
  UserSubscription? _currentSubscription;
  SubscriptionPlan? _selectedPlan;
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _message;
  String? _errorMessage;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _prefillUserData();
  }

  Future<void> _initializeData() async {
    try {
      await PaymentService.initialize();
      await _loadSubscriptionData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize payment service: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubscriptionData() async {
    try {
      final plans = await PaymentService.instance.getSubscriptionPlans();
      final currentSub = await PaymentService.instance.getCurrentSubscription();

      setState(() {
        _plans = plans;
        _currentSubscription = currentSub;
        _isLoading = false;
      });

      // Preselect plan by initial interval if provided via route arguments
      if (_selectedPlan == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args['initialInterval'] is String) {
          final String interval = (args['initialInterval'] as String).toLowerCase();
          final SubscriptionPlan match = plans.firstWhere(
            (p) => p.billingInterval.toLowerCase() == interval,
            orElse: () => plans.first,
          );
          setState(() {
            _selectedPlan = match;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load subscription data: $e';
        _isLoading = false;
      });
    }
  }

  void _prefillUserData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.userMetadata?['full_name'] ?? '';
    }
  }

  void _selectPlan(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlan == null) {
      setState(() {
        _errorMessage = 'Please select a subscription plan';
      });
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _message = 'Creating payment...';
      _errorMessage = null;
    });

    try {
      // Create billing details
      final billingDetails = stripe.BillingDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: stripe.Address(
          line1: _addressLine1Controller.text,
          line2: '',
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _zipCodeController.text,
          country: 'US',
        ),
      );

      // Create payment intent
      setState(() {
        _message = 'Processing payment...';
      });

      final paymentIntentResponse =
          await PaymentService.instance.createSubscriptionPayment(
        subscriptionPlanId: _selectedPlan!.id,
        billingDetails: billingDetails,
      );

      // Process payment
      final result = await PaymentService.instance.processSubscriptionPayment(
        clientSecret: paymentIntentResponse.clientSecret,
        billingDetails: billingDetails,
      );

      if (result.success) {
        // Ensure subscription record exists in Supabase (safety net)
        try {
          await PaymentService.instance.ensureSubscriptionRecord(
            subscriptionPlanId: _selectedPlan!.id,
            billingInterval: _selectedPlan!.billingInterval,
          );
        } catch (_) {}

        setState(() {
          _message = result.message;
          _errorMessage = null;
        });

        // Show success dialog and refresh data
        _showSuccessDialog(paymentIntentResponse.paymentIntentId);
        await _loadSubscriptionData();
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _message = null;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showSuccessDialog(String paymentIntentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Subscription Activated!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Your premium subscription has been activated successfully!'),
              SizedBox(height: 16),
              Text('Plan: ${_selectedPlan?.name}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Amount: ${_selectedPlan?.formattedPrice}'),
              SizedBox(height: 8),
              Text('Payment ID: $paymentIntentId',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🎉 You now have access to all premium features including unlimited journal entries, AI story generation, and advanced analytics!',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedPlan = null;
                  _message = null;
                  _errorMessage = null;
                });
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Platform indicator for development
                  if (kDebugMode)
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: kIsWeb ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            kIsWeb ? Icons.web : Icons.phone_android,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Platform: ${kIsWeb ? 'Web' : 'Mobile'} - Stripe Integration Active',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                      // Current subscription status
                      if (_currentSubscription != null)
                        CurrentSubscriptionWidget(
                          subscription: _currentSubscription!,
                          onCancel: _cancelSubscription,
                        ),

                  SizedBox(height: 24),

                      // Subscription plans
                      Text(
                    _currentSubscription?.isActive == true
                        ? 'Change Plan'
                        : 'Choose Your Plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                      // Plans list
                      ..._plans.map((plan) => Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SubscriptionPlanCard(
                          plan: plan,
                          isSelected: _selectedPlan?.id == plan.id,
                          onSelect: () => _selectPlan(plan),
                          isCurrentPlan:
                              _currentSubscription?.subscriptionPlan?.id ==
                                  plan.id,
                        ),
                      )),

                  SizedBox(height: 24),

                      // Payment form
                      if (_selectedPlan != null) ...[
                        PaymentFormWidget(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          addressLine1Controller: _addressLine1Controller,
                          cityController: _cityController,
                          stateController: _stateController,
                          zipCodeController: _zipCodeController,
                          selectedPlan: _selectedPlan!,
                          isProcessing: _isProcessingPayment,
                          message: _message,
                          errorMessage: _errorMessage,
                          onPayment: _processPayment,
                        ),
                      ],

                      SizedBox(height: 32),
                    ],
                  ),
                ),

          // Loading overlay during processing
          if (_isProcessingPayment) ...[
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(_message ?? 'Processing…'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription'),
        content: Text(
            'Are you sure you want to cancel your subscription? You\'ll lose access to premium features at the end of your billing period.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Cancel Subscription',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await PaymentService.instance.cancelSubscription();
      if (success) {
        await _loadSubscriptionData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription canceled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel subscription')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}
