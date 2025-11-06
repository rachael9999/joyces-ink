import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import './supabase_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  PaymentService._();

  final Dio _dio = Dio();
  final String _baseUrl = '${SupabaseService.supabaseUrl}/functions/v1';

  // Configurable trial days (from dart-define), default to 7
  static int get trialDays {
    final raw = const String.fromEnvironment('TRIAL_DAYS', defaultValue: '7');
    final parsed = int.tryParse(raw);
    return (parsed == null || parsed <= 0) ? 7 : parsed;
  }

  // Client-side defaults in case the backend table is not available
  List<SubscriptionPlan> get _defaultPlans => [
        SubscriptionPlan(
          id: 'default_monthly',
          name: 'Premium Monthly',
          description: 'Full premium access billed monthly',
          price: 4.99,
          currency: 'USD',
          billingInterval: 'month',
          features: const [
            'Unlimited AI Story Generation',
            'Advanced Cloud Sync',
            'Premium Themes & Analytics',
            'Priority Export & Support',
          ],
          isActive: true,
        ),
        SubscriptionPlan(
          id: 'default_yearly',
          name: 'Premium Yearly',
          description: 'Best value billed annually',
          price: 39.99,
          currency: 'USD',
          billingInterval: 'year',
          features: const [
            'Unlimited AI Story Generation',
            'Advanced Cloud Sync',
            'Premium Themes & Analytics',
            'Priority Export & Support',
            'Save over monthly',
          ],
          isActive: true,
        ),
      ];

  /// Initialize Stripe with publishable key
  static Future<void> initialize() async {
    try {
      const String publishableKey = String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

      if (publishableKey.isEmpty) {
        throw Exception(
            'STRIPE_PUBLISHABLE_KEY must be configured in env.json');
      }

      // Initialize Stripe for both platforms
      Stripe.publishableKey = publishableKey;

      // Initialize web-specific settings if on web
      if (kIsWeb) {
        await Stripe.instance.applySettings();
      }

      if (kDebugMode) {
        print(
            'Stripe initialized successfully for ${kIsWeb ? 'web' : 'mobile'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization error: $e');
      }
      rethrow;
    }
  }

  /// Create payment intent for subscription upgrade
  Future<PaymentIntentResponse> createSubscriptionPayment({
    required String subscriptionPlanId,
    BillingDetails? billingDetails,
  }) async {
    try {
      // Check authentication
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please login and try again.');
      }

      // Get the current session for access token
      final session = SupabaseService.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session found. Please login again.');
      }

      final response = await _dio.post(
        '$_baseUrl/create-payment-intent',
        data: {
          'subscription_plan_id': subscriptionPlanId,
          'billing_details': billingDetails?.toJson(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
          // Help diagnose CORS/network on web
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return PaymentIntentResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create payment intent: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      final code = e.response?.statusCode;
      final body = e.response?.data;
      final status = e.response?.statusMessage;

      if (body is Map && body['error'] != null) {
        errorMessage = 'Payment error: ${body['error']}';
      } else if (code != null) {
        errorMessage = 'Server error ($code): ${status ?? 'Unknown'}';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Network timeout. Please try again.';
      } else if (e.message?.contains('SocketException') == true) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMessage = 'Bad SSL certificate. Check your network or VPN.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Unexpected server response.';
      }

      if (kDebugMode) {
        print('createSubscriptionPayment error: ${e.toString()}');
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Process subscription payment using unified approach for both mobile and web
  Future<PaymentResult> processSubscriptionPayment({
    required String clientSecret,
    required BillingDetails billingDetails,
  }) async {
    try {
      // Validate client secret
      if (clientSecret.isEmpty) {
        throw Exception('Invalid payment configuration');
      }

      // Check if Stripe is properly initialized
      if (Stripe.publishableKey.isEmpty) {
        throw Exception('Payment service not properly initialized');
      }

      // Confirm payment directly with CardField data
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // Check payment status
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(
          success: true,
          message: 'Subscription activated successfully!',
          paymentIntentId: paymentIntent.id,
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment was not completed. Status: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: _getStripeErrorMessage(e),
        errorCode: e.error.code.name,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Get user's current subscription
  Future<UserSubscription?> getCurrentSubscription() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseService.instance.client
          .from('user_subscriptions')
          .select('*, subscription_plan:subscription_plans(*)')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response != null) {
        return UserSubscription.fromJson(response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subscription: $e');
      }
      return null;
    }
  }

  /// Get available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await SupabaseService.instance.client
          .from('subscription_plans')
          .select('*')
          .eq('is_active', true)
          .order('price');

      final list = (response as List)
          .map((plan) => SubscriptionPlan.fromJson(plan))
          .toList();

      if (list.isEmpty) return _defaultPlans;
      return list;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subscription plans: $e');
      }
      // Fallback to defaults if table missing or any error occurs
      return _defaultPlans;
    }
  }

  /// Cancel current subscription
  Future<bool> cancelSubscription() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return false;

      final subscription = await getCurrentSubscription();
      if (subscription == null) return false;

      await SupabaseService.instance.client.from('user_subscriptions').update({
        'status': 'canceled',
        'canceled_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', subscription.id);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling subscription: $e');
      }
      return false;
    }
  }

  /// Ensure there's an active subscription record for the current user.
  /// This is a safety net in case the backend does not create the record.
  /// Returns true if a valid active record exists or was created.
  Future<bool> ensureSubscriptionRecord({
    required String subscriptionPlanId,
    String? billingInterval,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return false;

      // If already has an active subscription, nothing to do
      final existing = await client
          .from('user_subscriptions')
          .select('id,status')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();
      if (existing != null) return true;

      // Determine interval: prefer provided value, else try DB, else infer
      String interval = billingInterval ?? 'month';
      int? planTrialDays;
      if (billingInterval == null) {
        try {
          final planResp = await client
              .from('subscription_plans')
              .select('id,billing_interval,trial_days')
              .eq('id', subscriptionPlanId)
              .maybeSingle();
          if (planResp != null) {
            interval = planResp['billing_interval'] ?? interval;
            if (planResp['trial_days'] is int) {
              planTrialDays = planResp['trial_days'] as int;
            }
          } else if (subscriptionPlanId.contains('year')) {
            interval = 'year';
          }
        } catch (_) {
          // table may not exist; infer from id
          if (subscriptionPlanId.contains('year')) interval = 'year';
        }
      }
      final now = DateTime.now().toUtc();
      DateTime periodEnd;
      if (interval == 'year') {
        periodEnd = DateTime.utc(now.year + 1, now.month, now.day,
            now.hour, now.minute, now.second);
      } else {
        // default monthly
        final int year = now.year + ((now.month + 1) > 12 ? 1 : 0);
        final int month = ((now.month) % 12) + 1;
        periodEnd = DateTime.utc(year, month, now.day,
            now.hour, now.minute, now.second);
      }

  // Trial window (configurable): prefer plan-specific, else dart-define
  final trialStart = now;
  final trialEnd = now.add(Duration(days: planTrialDays ?? trialDays));

      await client.from('user_subscriptions').insert({
        'user_id': user.id,
        'subscription_plan_id': subscriptionPlanId,
        'status': 'active',
        'current_period_start': now.toIso8601String(),
        'current_period_end': periodEnd.toIso8601String(),
        'trial_start': trialStart.toIso8601String(),
        'trial_end': trialEnd.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ensureSubscriptionRecord error: $e');
      }
      // Best-effort: if insert failed due to constraint or RLS, treat as not ensured
      return false;
    }
  }

  /// Get user-friendly error message from Stripe error
  String _getStripeErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Payment was cancelled';
      case FailureCode.Failed:
        return 'Payment failed. Please try again.';
      case FailureCode.Timeout:
        return 'Payment timed out. Please try again.';
      default:
        return e.error.localizedMessage ?? 'Payment failed. Please try again.';
    }
  }
}

/// Payment Intent Response model
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final String transactionId;
  final double amount;
  final String currency;
  final String description;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.description,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['client_secret'],
      paymentIntentId: json['payment_intent_id'],
      transactionId: json['transaction_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      description: json['description'] ?? '',
    );
  }
}

/// Payment Result model
class PaymentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? paymentIntentId;

  PaymentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.paymentIntentId,
  });
}

/// Subscription Plan model
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingInterval;
  final List<String> features;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.features,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      billingInterval: json['billing_interval'],
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] ?? false,
    );
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}/${billingInterval == 'year' ? 'year' : 'month'}';
  }

  String get billingIntervalDisplay {
    return billingInterval == 'year' ? 'Annually' : 'Monthly';
  }
}

/// User Subscription model
class UserSubscription {
  final String id;
  final String userId;
  final String subscriptionPlanId;
  final String? stripeSubscriptionId;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialStart;
  final DateTime? trialEnd;
  final DateTime? canceledAt;
  final SubscriptionPlan? subscriptionPlan;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    this.stripeSubscriptionId,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialStart,
    this.trialEnd,
    this.canceledAt,
    this.subscriptionPlan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      subscriptionPlanId: json['subscription_plan_id'],
      stripeSubscriptionId: json['stripe_subscription_id'],
      status: json['status'],
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'])
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'])
          : null,
      trialStart: json['trial_start'] != null
          ? DateTime.parse(json['trial_start'])
          : null,
      trialEnd:
          json['trial_end'] != null ? DateTime.parse(json['trial_end']) : null,
      canceledAt: json['canceled_at'] != null
          ? DateTime.parse(json['canceled_at'])
          : null,
      subscriptionPlan: json['subscription_plan'] != null
          ? SubscriptionPlan.fromJson(json['subscription_plan'])
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isCanceled => status == 'canceled';
  bool get isPastDue => status == 'past_due';

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'canceled':
        return 'Canceled';
      case 'past_due':
        return 'Past Due';
      case 'trialing':
        return 'Trial';
      default:
        return 'Inactive';
    }
  }

  DateTime? get nextBillingDate {
    if (currentPeriodEnd != null && isActive) {
      return currentPeriodEnd;
    }
    return null;
  }
}
