import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: corsHeaders
        });
    }
    
    try {
        // Get the authorization token from the request headers
        const authHeader = req.headers.get('Authorization');
        if (!authHeader) {
            throw new Error('Missing Authorization header');
        }

        // Create a Supabase client
        const supabaseUrl = Deno.env.get('SUPABASE_URL');
        const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
        const supabase = createClient(supabaseUrl, supabaseKey, {
            global: { headers: { Authorization: authHeader } }
        });
        
        // Create a Stripe client
        const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
        const stripe = new Stripe(stripeKey);
        
        // Get the request body
        const requestData = await req.json();
        const { subscription_plan_id, billing_details } = requestData;

        // Validate input data
        if (!subscription_plan_id) {
            throw new Error('Subscription plan ID is required');
        }

        // Get user information from JWT token
        const { data: { user }, error: userError } = await supabase.auth.getUser();
        if (userError || !user) {
            throw new Error('User not authenticated');
        }

        // Get subscription plan details
        const { data: plan, error: planError } = await supabase
            .from('subscription_plans')
            .select('*')
            .eq('id', subscription_plan_id)
            .eq('is_active', true)
            .single();

        if (planError || !plan) {
            throw new Error('Invalid subscription plan');
        }

        // Create a Stripe payment intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(plan.price * 100), // Convert to cents
            currency: plan.currency.toLowerCase(),
            automatic_payment_methods: { enabled: true },
            description: `Joyce's Ink - ${plan.name} Subscription`,
            metadata: {
                user_id: user.id,
                subscription_plan_id: plan.id,
                plan_name: plan.name,
                billing_interval: plan.billing_interval
            },
            receipt_email: user.email
        });

        // Create payment transaction record
        const { data: transaction, error: transactionError } = await supabase
            .from('payment_transactions')
            .insert({
                user_id: user.id,
                stripe_payment_intent_id: paymentIntent.id,
                amount: plan.price,
                currency: plan.currency,
                status: 'pending',
                description: `Payment for ${plan.name} subscription`,
                metadata: {
                    subscription_plan_id: plan.id,
                    billing_interval: plan.billing_interval
                }
            })
            .select()
            .single();

        if (transactionError) {
            throw new Error(`Error creating transaction record: ${transactionError.message}`);
        }

        // Return the payment intent client secret
        return new Response(JSON.stringify({
            client_secret: paymentIntent.client_secret,
            payment_intent_id: paymentIntent.id,
            transaction_id: transaction.id,
            amount: plan.price,
            currency: plan.currency,
            description: plan.description
        }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 200
        });
        
    } catch (error) {
        console.error('Create payment intent error:', error.message);
        return new Response(JSON.stringify({
            error: error.message
        }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 400
        });
    }
});