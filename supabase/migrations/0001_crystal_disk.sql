/*
  # Initial schema setup for blog application

  1. Tables
    - profiles: User profiles linked to auth.users
    - categories: Blog post categories
    - posts: Blog posts with author and category references
    - comments: Post comments
    - bookmarks: User post bookmarks

  2. Security
    - Enable RLS on all tables
    - Set up policies for authenticated and public access
*/

DO $$ 
BEGIN

-- Create tables if they don't exist
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  slug text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL,
  content text NOT NULL,
  excerpt text,
  author_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  published boolean DEFAULT false,
  views integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(slug)
);

CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, post_id)
);

END $$;

-- Enable Row Level Security
DO $$ 
BEGIN
  EXECUTE 'ALTER TABLE profiles ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE categories ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE posts ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE comments ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY';
EXCEPTION 
  WHEN others THEN NULL;
END $$;

-- Drop existing policies if they exist
DO $$ 
BEGIN
  -- Profiles policies
  DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
  DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
  DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
  
  -- Categories policies
  DROP POLICY IF EXISTS "Categories are viewable by everyone" ON categories;
  DROP POLICY IF EXISTS "Only authenticated users can create categories" ON categories;
  
  -- Posts policies
  DROP POLICY IF EXISTS "Published posts are viewable by everyone" ON posts;
  DROP POLICY IF EXISTS "Authenticated users can create posts" ON posts;
  DROP POLICY IF EXISTS "Users can update own posts" ON posts;
  DROP POLICY IF EXISTS "Users can delete own posts" ON posts;
  
  -- Comments policies
  DROP POLICY IF EXISTS "Comments are viewable by everyone" ON comments;
  DROP POLICY IF EXISTS "Authenticated users can create comments" ON comments;
  DROP POLICY IF EXISTS "Users can update own comments" ON comments;
  DROP POLICY IF EXISTS "Users can delete own comments" ON comments;
  
  -- Bookmarks policies
  DROP POLICY IF EXISTS "Users can view own bookmarks" ON bookmarks;
  DROP POLICY IF EXISTS "Users can create own bookmarks" ON bookmarks;
  DROP POLICY IF EXISTS "Users can delete own bookmarks" ON bookmarks;
END $$;

-- Create new policies
-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Categories policies
CREATE POLICY "Categories are viewable by everyone"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Only authenticated users can create categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Posts policies
CREATE POLICY "Published posts are viewable by everyone"
  ON posts FOR SELECT
  USING (published = true OR auth.uid() = author_id);

CREATE POLICY "Authenticated users can create posts"
  ON posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = author_id);

CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = author_id);

-- Comments policies
CREATE POLICY "Comments are viewable by everyone"
  ON comments FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create comments"
  ON comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
  ON comments FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
  ON comments FOR DELETE
  USING (auth.uid() = user_id);

-- Bookmarks policies
CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own bookmarks"
  ON bookmarks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'posts_author_id_idx') THEN
    CREATE INDEX posts_author_id_idx ON posts(author_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'posts_category_id_idx') THEN
    CREATE INDEX posts_category_id_idx ON posts(category_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'comments_post_id_idx') THEN
    CREATE INDEX comments_post_id_idx ON comments(post_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'comments_user_id_idx') THEN
    CREATE INDEX comments_user_id_idx ON comments(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'bookmarks_user_id_idx') THEN
    CREATE INDEX bookmarks_user_id_idx ON bookmarks(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'bookmarks_post_id_idx') THEN
    CREATE INDEX bookmarks_post_id_idx ON bookmarks(post_id);
  END IF;
END $$;