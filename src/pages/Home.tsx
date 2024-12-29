import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { formatDistanceToNow } from 'date-fns';

interface Post {
  id: string;
  title: string;
  excerpt: string;
  slug: string;
  created_at: string;
  profiles: {
    username: string;
  };
  categories: {
    name: string;
  };
}

export default function Home() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchPosts() {
      const { data, error } = await supabase
        .from('posts')
        .select(`
          id,
          title,
          excerpt,
          slug,
          created_at,
          profiles (username),
          categories (name)
        `)
        .eq('published', true)
        .order('created_at', { ascending: false });

      if (!error && data) {
        setPosts(data);
      }
      setLoading(false);
    }

    fetchPosts();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-8">Latest Posts</h1>
      <div className="space-y-8">
        {posts.map((post) => (
          <article key={post.id} className="bg-white rounded-lg shadow-sm p-6">
            <Link to={`/posts/${post.slug}`}>
              <h2 className="text-2xl font-bold mb-2 hover:text-blue-600">
                {post.title}
              </h2>
            </Link>
            <div className="text-sm text-gray-500 mb-4">
              <span>{post.profiles.username}</span>
              <span className="mx-2">·</span>
              <span>{formatDistanceToNow(new Date(post.created_at))} ago</span>
              {post.categories && (
                <>
                  <span className="mx-2">·</span>
                  <span>{post.categories.name}</span>
                </>
              )}
            </div>
            <p className="text-gray-600">{post.excerpt}</p>
            <Link
              to={`/posts/${post.slug}`}
              className="inline-block mt-4 text-blue-600 hover:text-blue-800"
            >
              Read more →
            </Link>
          </article>
        ))}
      </div>
    </div>
  );
}