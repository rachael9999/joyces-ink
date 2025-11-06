import 'dart:math' as math;

// no external Flutter imports required

import 'auth_service.dart';
import 'storage_metrics_service.dart';
import 'story_service.dart';
import 'payment_service.dart';

enum SubscriptionPlan { free, premium }

class PlanLimits {
  final int? maxStoriesGenerated; // null => unlimited
  final int? maxStorageBytes; // null => unlimited
  final int allowedExportFormats; // e.g. 1 free, 2 premium

  const PlanLimits({
    required this.maxStoriesGenerated,
    required this.maxStorageBytes,
    required this.allowedExportFormats,
  });
}

class SubscriptionService {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  Future<SubscriptionPlan> getCurrentPlan() async {
    try {
      // First, honor an active paid subscription from the backend if present
      try {
        final sub = await PaymentService.instance.getCurrentSubscription();
        if (sub != null && sub.isActive) {
          return SubscriptionPlan.premium;
        }
      } catch (_) {
        // ignore payment lookup errors and fallback to profile role
      }
      final profile = await AuthService.instance.getUserProfile();
      final role = (profile?['role'] ?? '').toString().toLowerCase();
      if (role == 'premium' || role == 'pro' || role == 'paid') return SubscriptionPlan.premium;
      return SubscriptionPlan.free;
    } catch (_) {
      return SubscriptionPlan.free;
    }
  }

  PlanLimits limitsFor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.premium:
        return const PlanLimits(
          maxStoriesGenerated: null,
          maxStorageBytes: null,
          allowedExportFormats: 2,
        );
      case SubscriptionPlan.free:
        return const PlanLimits(
          maxStoriesGenerated: 5,
          maxStorageBytes: 5 * 1024 * 1024, // 5 MB
          allowedExportFormats: 1,
        );
    }
  }

  Future<bool> canGenerateMoreStories() async {
    final plan = await getCurrentPlan();
    final limits = limitsFor(plan);
    if (limits.maxStoriesGenerated == null) return true;
    try {
      final stories = await StoryService.instance.getGeneratedStories();
      return stories.length < (limits.maxStoriesGenerated ?? 1 << 30);
    } catch (_) {
      // Fail-open to avoid false negatives
      return true;
    }
  }

  Future<bool> canStoreMoreData({int additionalBytes = 0}) async {
    final plan = await getCurrentPlan();
    final limits = limitsFor(plan);
    if (limits.maxStorageBytes == null) return true;
    try {
      final used = await StorageMetricsService.instance.computeTotalBytes();
      final total = used + math.max(0, additionalBytes);
      return total <= (limits.maxStorageBytes ?? 1 << 60);
    } catch (_) {
      // Fail-open
      return true;
    }
  }

  int allowedExportFormats(SubscriptionPlan plan) => limitsFor(plan).allowedExportFormats;
}
