import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature'
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
        const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')!;
        const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;

        const supabase = createClient(supabaseUrl, supabaseServiceKey);
        const stripe = new Stripe(stripeSecretKey);

        const signature = req.headers.get('stripe-signature');
        const body = await req.text();

        let event: Stripe.Event;
        try {
            event = stripe.webhooks.constructEvent(body, signature!, stripeWebhookSecret);
        } catch (err) {
            throw new Error(`Webhook signature verification failed: ${err.message}`);
        }

        console.log(`Processing webhook event: ${event.type}`);

        switch (event.type) {
            case 'payment_intent.succeeded': {
                const paymentIntent = event.data.object as Stripe.PaymentIntent;
                
                // Update payment transaction
                const { error: txnError } = await supabase
                    .from('payment_transactions')
                    .update({ 
                        status: 'succeeded',
                        stripe_payment_method_id: paymentIntent.payment_method as string,
                        updated_at: new Date().toISOString()
                    })
                    .eq('stripe_payment_intent_id', paymentIntent.id);

                if (txnError) {
                    throw new Error(`Failed to update transaction: ${txnError.message}`);
                }

                // Create or update subscription
                const userId = paymentIntent.metadata.user_id;
                const subscriptionPlanId = paymentIntent.metadata.subscription_plan_id;
                const billingInterval = paymentIntent.metadata.billing_interval;

                if (userId && subscriptionPlanId) {
                    const now = new Date();
                    const periodEnd = new Date(now);
                    
                    // Calculate subscription period
                    if (billingInterval === 'year') {
                        periodEnd.setFullYear(periodEnd.getFullYear() + 1);
                    } else {
                        periodEnd.setMonth(periodEnd.getMonth() + 1);
                    }

                    // Check if user already has an active subscription
                    const { data: existingSub } = await supabase
                        .from('user_subscriptions')
                        .select('*')
                        .eq('user_id', userId)
                        .eq('status', 'active')
                        .single();

                    if (existingSub) {
                        // Update existing subscription
                        const { error: subError } = await supabase
                            .from('user_subscriptions')
                            .update({
                                subscription_plan_id: subscriptionPlanId,
                                current_period_start: now.toISOString(),
                                current_period_end: periodEnd.toISOString(),
                                status: 'active',
                                updated_at: new Date().toISOString()
                            })
                            .eq('id', existingSub.id);

                        if (subError) {
                            throw new Error(`Failed to update subscription: ${subError.message}`);
                        }
                    } else {
                        // Create new subscription
                        const { error: subError } = await supabase
                            .from('user_subscriptions')
                            .insert({
                                user_id: userId,
                                subscription_plan_id: subscriptionPlanId,
                                status: 'active',
                                current_period_start: now.toISOString(),
                                current_period_end: periodEnd.toISOString()
                            });

                        if (subError) {
                            throw new Error(`Failed to create subscription: ${subError.message}`);
                        }
                    }

                    console.log(`Successfully processed payment for user ${userId}`);
                }
                break;
            }

            case 'payment_intent.payment_failed': {
                const paymentIntent = event.data.object as Stripe.PaymentIntent;
                
                const { error } = await supabase
                    .from('payment_transactions')
                    .update({ 
                        status: 'failed',
                        updated_at: new Date().toISOString()
                    })
                    .eq('stripe_payment_intent_id', paymentIntent.id);

                if (error) {
                    throw new Error(`Failed to update failed payment: ${error.message}`);
                }
                break;
            }

            case 'invoice.payment_succeeded': {
                const invoice = event.data.object as Stripe.Invoice;
                if (invoice.subscription) {
                    // Handle recurring subscription payments
                    const { data: subscription } = await supabase
                        .from('user_subscriptions')
                        .select('*')
                        .eq('stripe_subscription_id', invoice.subscription)
                        .single();

                    if (subscription) {
                        const periodEnd = new Date(invoice.lines.data[0].period.end * 1000);
                        
                        const { error } = await supabase
                            .from('user_subscriptions')
                            .update({
                                current_period_end: periodEnd.toISOString(),
                                status: 'active',
                                updated_at: new Date().toISOString()
                            })
                            .eq('stripe_subscription_id', invoice.subscription);

                        if (error) {
                            throw new Error(`Failed to update subscription: ${error.message}`);
                        }
                    }
                }
                break;
            }

            case 'customer.subscription.deleted': {
                const subscription = event.data.object as Stripe.Subscription;
                
                const { error } = await supabase
                    .from('user_subscriptions')
                    .update({ 
                        status: 'canceled',
                        canceled_at: new Date().toISOString(),
                        updated_at: new Date().toISOString()
                    })
                    .eq('stripe_subscription_id', subscription.id);

                if (error) {
                    throw new Error(`Failed to cancel subscription: ${error.message}`);
                }
                break;
            }

            default:
                console.log(`Unhandled event type: ${event.type}`);
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200
        });

    } catch (error) {
        console.error('Webhook error:', error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400
        });
    }
});