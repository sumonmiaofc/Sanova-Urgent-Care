-- =========================================================
-- SANOVA BLOG SYSTEM — Complete Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- =========================================================

-- 1. Categories table
CREATE TABLE IF NOT EXISTS categories (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name       text NOT NULL,
  slug       text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- 2. Blogs table
CREATE TABLE IF NOT EXISTS blogs (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title            text NOT NULL,
  slug             text UNIQUE NOT NULL,
  excerpt          text,
  content          text,
  featured_image   text,
  category_id      uuid REFERENCES categories(id) ON DELETE SET NULL,
  author           text DEFAULT 'Sanova Medical Team',
  meta_title       text,
  meta_description text,
  faq              jsonb DEFAULT '[]',
  published        boolean DEFAULT false,
  views            integer DEFAULT 0,
  created_at       timestamptz DEFAULT now(),
  updated_at       timestamptz DEFAULT now(),
  published_at     timestamptz
);

-- 3. Analytics table
CREATE TABLE IF NOT EXISTS analytics (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  blog_id    uuid REFERENCES blogs(id) ON DELETE CASCADE,
  views      integer DEFAULT 0,
  visitors   integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- 4. Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

-- 5. Policies — public read published blogs
DROP POLICY IF EXISTS "Public read categories" ON categories;
CREATE POLICY "Public read categories"
  ON categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read published blogs" ON blogs;
CREATE POLICY "Public read published blogs"
  ON blogs FOR SELECT USING (published = true);

DROP POLICY IF EXISTS "Admin all blogs" ON blogs;
CREATE POLICY "Admin all blogs"
  ON blogs FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin all categories" ON categories;
CREATE POLICY "Admin all categories"
  ON categories FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin all analytics" ON analytics;
CREATE POLICY "Admin all analytics"
  ON analytics FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Public insert analytics" ON analytics;
CREATE POLICY "Public insert analytics"
  ON analytics FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update views" ON blogs;
CREATE POLICY "Public update views"
  ON blogs FOR UPDATE USING (true) WITH CHECK (true);

-- 6. Indexes
CREATE INDEX IF NOT EXISTS blogs_slug_idx ON blogs(slug);
CREATE INDEX IF NOT EXISTS blogs_published_idx ON blogs(published);
CREATE INDEX IF NOT EXISTS blogs_category_idx ON blogs(category_id);

-- 7. Seed default categories
INSERT INTO categories (name, slug) VALUES
  ('Health Tips', 'health-tips'),
  ('Urgent Care', 'urgent-care'),
  ('IV Therapy', 'iv-therapy'),
  ('Prevention', 'prevention'),
  ('Arizona Health', 'arizona-health'),
  ('Insurance & Billing', 'insurance-billing'),
  ('Wellness', 'wellness'),
  ('Physicals', 'physicals')
ON CONFLICT (slug) DO NOTHING;

-- 8. Storage bucket for blog images
INSERT INTO storage.buckets (id, name, public)
VALUES ('blog-images', 'blog-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read blog images"
  ON storage.objects FOR SELECT USING (bucket_id = 'blog-images');

CREATE POLICY "Auth upload blog images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'blog-images' AND auth.role() = 'authenticated');

CREATE POLICY "Auth delete blog images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'blog-images' AND auth.role() = 'authenticated');

-- =========================================================
-- DONE! Now go to Authentication → Users → Add User
-- =========================================================
