-- Add share asset fields to generated_stories
ALTER TABLE public.generated_stories
  ADD COLUMN IF NOT EXISTS share_clip TEXT,
  ADD COLUMN IF NOT EXISTS share_image_url TEXT;

-- Optional: index for faster lookups by share_image_url (if needed)
CREATE INDEX IF NOT EXISTS idx_generated_stories_share_image_url ON public.generated_stories(share_image_url);
