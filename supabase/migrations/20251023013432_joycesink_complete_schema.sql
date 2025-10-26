-- Location: supabase/migrations/20251023013432_joycesink_complete_schema.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete new schema creation for journaling app
-- Dependencies: None (fresh project)

-- 1. TYPES AND ENUMS
CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'free');
CREATE TYPE public.mood_type AS ENUM ('happy', 'sad', 'anxious', 'excited', 'calm', 'angry', 'neutral');
CREATE TYPE public.story_genre AS ENUM ('fantasy', 'romance', 'adventure', 'mystery', 'sci_fi', 'drama', 'thriller', 'comedy');
CREATE TYPE public.thought_category AS ENUM ('philosophy', 'business_ideas', 'random_thoughts', 'story_ideas', 'random_facts', 'uncategorized');

-- 2. CORE TABLES (No foreign keys first)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    role public.user_role DEFAULT 'free'::public.user_role,
    writing_streak INTEGER DEFAULT 0,
    total_entries INTEGER DEFAULT 0,
    stories_generated INTEGER DEFAULT 0,
    daily_goal INTEGER DEFAULT 300,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    member_since TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. DEPENDENT TABLES (With foreign keys)
CREATE TABLE public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT NOT NULL,
    preview TEXT NOT NULL,
    mood public.mood_type NOT NULL,
    word_count INTEGER DEFAULT 0,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.generated_stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    journal_entry_id UUID REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    genre public.story_genre NOT NULL,
    word_count INTEGER DEFAULT 0,
    reading_time_minutes INTEGER DEFAULT 0,
    rating INTEGER CHECK (rating >= 0 AND rating <= 5),
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.thoughts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    category public.thought_category DEFAULT 'uncategorized'::public.thought_category,
    word_count INTEGER DEFAULT 0,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.story_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID REFERENCES public.generated_stories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. INDEXES
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_journal_entries_user_id ON public.journal_entries(user_id);
CREATE INDEX idx_journal_entries_created_at ON public.journal_entries(created_at DESC);
CREATE INDEX idx_generated_stories_user_id ON public.generated_stories(user_id);
CREATE INDEX idx_generated_stories_journal_entry_id ON public.generated_stories(journal_entry_id);
CREATE INDEX idx_thoughts_user_id ON public.thoughts(user_id);
CREATE INDEX idx_thoughts_category ON public.thoughts(category);
CREATE INDEX idx_story_comments_story_id ON public.story_comments(story_id);
CREATE INDEX idx_story_comments_user_id ON public.story_comments(user_id);

-- 5. FUNCTIONS (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'free')::public.user_role
  );
  RETURN NEW;
END;
$func$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

-- 6. ENABLE RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.generated_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thoughts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.story_comments ENABLE ROW LEVEL SECURITY;

-- 7. RLS POLICIES (Using Pattern 1 and Pattern 2)
-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for other tables
CREATE POLICY "users_manage_own_journal_entries"
ON public.journal_entries
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_generated_stories"
ON public.generated_stories
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_thoughts"
ON public.thoughts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_story_comments"
ON public.story_comments
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. TRIGGERS
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_generated_stories_updated_at
    BEFORE UPDATE ON public.generated_stories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_thoughts_updated_at
    BEFORE UPDATE ON public.thoughts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_story_comments_updated_at
    BEFORE UPDATE ON public.story_comments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 9. MOCK DATA
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    entry1_id UUID := gen_random_uuid();
    entry2_id UUID := gen_random_uuid();
    story1_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with all required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'sarah.johnson@joycesink.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Johnson", "role": "premium"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'demo@joycesink.com', crypt('demo123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Demo User", "role": "free"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create journal entries
    INSERT INTO public.journal_entries (id, user_id, title, content, preview, mood, word_count, created_at) VALUES
        (entry1_id, admin_uuid, 'A Day of Discovery', 
         'Today was an incredible day filled with new discoveries and meaningful conversations. I met an old friend at the coffee shop and we talked for hours about our dreams and aspirations. It reminded me of how important it is to maintain connections with people who truly understand you.',
         'Today was an incredible day filled with new discoveries and meaningful conversations.',
         'happy'::public.mood_type, 245, NOW() - INTERVAL '2 hours'),
        (entry2_id, admin_uuid, 'Finding Balance',
         'Feeling a bit overwhelmed with work lately. The deadlines are piling up and I am struggling to find balance between my professional and personal life. I need to remember to take breaks and practice self-care.',
         'Feeling a bit overwhelmed with work lately.',
         'anxious'::public.mood_type, 189, NOW() - INTERVAL '1 day');

    -- Create generated stories
    INSERT INTO public.generated_stories (id, user_id, journal_entry_id, title, content, genre, word_count, reading_time_minutes, rating, is_favorite) VALUES
        (story1_id, admin_uuid, entry1_id, 'The Midnight Garden Secret', 
         'In the heart of the old Victorian mansion, behind walls covered in ivy and memories, lay a garden that only revealed its true nature when the clock struck midnight. Sarah had discovered this peculiar place three weeks ago, during one of her restless nights. The journal entry she had written that evening about feeling lost and searching for purpose had somehow transformed into this enchanting tale of mystery and self-discovery.',
         'fantasy'::public.story_genre, 342, 3, 4, true);

    -- Create thoughts
    INSERT INTO public.thoughts (user_id, content, category, word_count, is_favorite) VALUES
        (admin_uuid, 'The way morning light filters through window blinds reminds me of prison bars - but instead of keeping us in, they are keeping the darkness out.', 'philosophy'::public.thought_category, 25, false),
        (admin_uuid, 'Business idea: An app that connects people who want to learn new skills with those who want to teach them, but only in person. Like Airbnb for knowledge exchange.', 'business_ideas'::public.thought_category, 32, true),
        (user_uuid, 'What if dreams are just our brain way of defragmenting our memories? Like a computer organizing files while we sleep.', 'random_thoughts'::public.thought_category, 22, false);

    -- Create story comments
    INSERT INTO public.story_comments (story_id, user_id, content) VALUES
        (story1_id, admin_uuid, 'This story really resonated with me. The garden metaphor perfectly captures how I have been feeling about my own creative journey lately.'),
        (story1_id, admin_uuid, 'I love how the AI transformed my simple journal entry about feeling lost into such a beautiful narrative.');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 10. CLEANUP FUNCTION
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%joycesink.com' OR email = 'demo@joycesink.com';

    -- Delete in dependency order (children first)
    DELETE FROM public.story_comments WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.thoughts WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.generated_stories WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.journal_entries WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);
    
    -- Delete auth.users last
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$func$;