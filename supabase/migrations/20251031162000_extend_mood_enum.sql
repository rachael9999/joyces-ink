-- Extend the mood enum used by journal_entries.mood to support 10 distinct values
-- Adds: confident, loved, tired, thoughtful, peaceful
-- Safe to run multiple times; no-op if values already exist or column is not enum.

DO $$
DECLARE 
  v_typname text;
  v_nspname text;
BEGIN
  -- Detect the enum type backing journal_entries.mood
  SELECT t.typname, n.nspname
  INTO v_typname, v_nspname
  FROM pg_type t
  JOIN pg_namespace n ON n.oid = t.typnamespace
  JOIN pg_attribute a ON a.atttypid = t.oid
  JOIN pg_class c ON c.oid = a.attrelid
  WHERE c.relname = 'journal_entries'
    AND a.attname = 'mood'
    AND t.typtype = 'e'  -- enum
  LIMIT 1;

  IF v_typname IS NULL THEN
    RAISE NOTICE 'journal_entries.mood is not an enum type; skipping enum extension.';
    RETURN;
  END IF;

  -- Add each new enum label if missing
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t2 ON t2.oid = e.enumtypid
    WHERE t2.typname = v_typname AND e.enumlabel = 'confident') THEN
    EXECUTE format('ALTER TYPE %I.%I ADD VALUE IF NOT EXISTS %L', v_nspname, v_typname, 'confident');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t2 ON t2.oid = e.enumtypid
    WHERE t2.typname = v_typname AND e.enumlabel = 'loved') THEN
    EXECUTE format('ALTER TYPE %I.%I ADD VALUE IF NOT EXISTS %L', v_nspname, v_typname, 'loved');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t2 ON t2.oid = e.enumtypid
    WHERE t2.typname = v_typname AND e.enumlabel = 'tired') THEN
    EXECUTE format('ALTER TYPE %I.%I ADD VALUE IF NOT EXISTS %L', v_nspname, v_typname, 'tired');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t2 ON t2.oid = e.enumtypid
    WHERE t2.typname = v_typname AND e.enumlabel = 'thoughtful') THEN
    EXECUTE format('ALTER TYPE %I.%I ADD VALUE IF NOT EXISTS %L', v_nspname, v_typname, 'thoughtful');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t2 ON t2.oid = e.enumtypid
    WHERE t2.typname = v_typname AND e.enumlabel = 'peaceful') THEN
    EXECUTE format('ALTER TYPE %I.%I ADD VALUE IF NOT EXISTS %L', v_nspname, v_typname, 'peaceful');
  END IF;

  RAISE NOTICE 'Mood enum % updated with additional values (if missing).', v_typname;
END $$ LANGUAGE plpgsql;