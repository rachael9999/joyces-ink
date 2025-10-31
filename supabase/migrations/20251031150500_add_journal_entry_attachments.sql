-- Adds attachments table for journal entries
CREATE TABLE IF NOT EXISTS public.journal_entry_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.journal_entry_attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_manage_own_journal_entry_attachments"
ON public.journal_entry_attachments
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_journal_entry_attachments_entry_id ON public.journal_entry_attachments(entry_id);