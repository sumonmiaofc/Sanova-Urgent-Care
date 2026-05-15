-- =========================================================
-- SANOVA BLOG — Supabase SQL Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- =========================================================

-- 1. Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title         text NOT NULL,
  slug          text UNIQUE NOT NULL,
  excerpt       text,
  content       text,
  author        text DEFAULT 'Sanova Medical Team',
  category      text DEFAULT 'Health Tips',
  status        text DEFAULT 'draft' CHECK (status IN ('draft','published')),
  cover_image   text,
  created_at    timestamptz DEFAULT now(),
  published_at  timestamptz
);

-- 2. Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- 3. Public can READ published posts only
CREATE POLICY "Public read published posts"
  ON posts FOR SELECT
  USING (status = 'published');

-- 4. Authenticated users (admin) can do everything
CREATE POLICY "Admin full access"
  ON posts FOR ALL
  USING (auth.role() = 'authenticated');

-- 5. Create index for slug lookups
CREATE INDEX IF NOT EXISTS posts_slug_idx ON posts(slug);
CREATE INDEX IF NOT EXISTS posts_status_idx ON posts(status);

-- =========================================================
-- DONE! Now go to Supabase → Authentication → Add a user
-- Email: your admin email
-- Password: strong password
-- This will be your admin login
-- =========================================================
