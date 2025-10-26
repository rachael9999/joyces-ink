-- Location: supabase/migrations/20251023023518_subscription_management.sql
-- Schema Analysis: Existing journaling app with user_profiles table, user_role enum (free, premium, admin)
-- Integration Type: Addition - Adding subscription management tables
-- Dependencies: Existing user_profiles table

-- 1. Types for subscription management
CREATE TYPE public.subscription_status AS ENUM ('active', 'inactive', 'canceled', 'past_due', 'trialing');
CREATE TYPE public.payment_status AS ENUM ('pending', 'succeeded', 'failed', 'canceled', 'refunded');

-- 2. Subscription plans table
CREATE TABLE public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    billing_interval TEXT NOT NULL CHECK (billing_interval IN ('month', 'year')),
    stripe_price_id TEXT,
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. User subscriptions table
CREATE TABLE public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subscription_plan_id UUID REFERENCES public.subscription_plans(id) ON DELETE RESTRICT,
    stripe_subscription_id TEXT UNIQUE,
    status public.subscription_status DEFAULT 'inactive'::public.subscription_status,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    canceled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Payment transactions table
CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    user_subscription_id UUID REFERENCES public.user_subscriptions(id) ON DELETE SET NULL,
    stripe_payment_intent_id TEXT,
    stripe_payment_method_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    status public.payment_status DEFAULT 'pending'::public.payment_status,
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Essential Indexes
CREATE INDEX idx_subscription_plans_active ON public.subscription_plans(is_active);
CREATE INDEX idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_stripe_id ON public.user_subscriptions(stripe_subscription_id);
CREATE INDEX idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status);
CREATE INDEX idx_payment_transactions_stripe_intent ON public.payment_transactions(stripe_payment_intent_id);

-- 6. Functions for subscription management
CREATE OR REPLACE FUNCTION public.update_user_role_on_subscription()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    -- Update user role based on subscription status
    IF NEW.status = 'active' THEN
        UPDATE public.user_profiles 
        SET role = 'premium'::public.user_role, updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.user_id;
    ELSIF OLD.status = 'active' AND NEW.status IN ('inactive', 'canceled', 'past_due') THEN
        UPDATE public.user_profiles 
        SET role = 'free'::public.user_role, updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$func$;

-- 7. Enable RLS for all tables
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies

-- Subscription plans - public read, admin manage
CREATE POLICY "public_can_read_subscription_plans"
ON public.subscription_plans
FOR SELECT
TO public
USING (is_active = true);

-- User subscriptions - users manage their own
CREATE POLICY "users_manage_own_subscriptions"
ON public.user_subscriptions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Payment transactions - users manage their own
CREATE POLICY "users_manage_own_transactions"
ON public.payment_transactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admin access function
CREATE OR REPLACE FUNCTION public.has_admin_role()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
)
$$;

-- Admin policies for subscription management
CREATE POLICY "admin_manage_subscription_plans"
ON public.subscription_plans
FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "admin_view_all_subscriptions"
ON public.user_subscriptions
FOR SELECT
TO authenticated
USING (public.has_admin_role());

CREATE POLICY "admin_view_all_transactions"
ON public.payment_transactions
FOR SELECT
TO authenticated
USING (public.has_admin_role());

-- 9. Triggers
CREATE TRIGGER update_subscription_plans_updated_at
    BEFORE UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
    BEFORE UPDATE ON public.user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_payment_transactions_updated_at
    BEFORE UPDATE ON public.payment_transactions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_role_on_subscription_change
    AFTER INSERT OR UPDATE ON public.user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_user_role_on_subscription();

-- 10. Mock Data for subscription plans
DO $$
DECLARE
    basic_plan_id UUID := gen_random_uuid();
    premium_plan_id UUID := gen_random_uuid();
BEGIN
    -- Insert subscription plans
    INSERT INTO public.subscription_plans (id, name, description, price, currency, billing_interval, features, is_active)
    VALUES
        (basic_plan_id, 'Premium Monthly', 'Access to premium features including unlimited journal entries, AI story generation, and advanced analytics', 9.99, 'USD', 'month', 
         '["Unlimited journal entries", "AI story generation", "Advanced analytics", "Export to PDF", "Cloud sync", "Priority support"]'::jsonb, true),
        (premium_plan_id, 'Premium Yearly', 'Annual premium plan with 2 months free - same great features', 99.99, 'USD', 'year',
         '["Unlimited journal entries", "AI story generation", "Advanced analytics", "Export to PDF", "Cloud sync", "Priority support", "2 months free"]'::jsonb, true);

    RAISE NOTICE 'Subscription plans created successfully';
END $$;