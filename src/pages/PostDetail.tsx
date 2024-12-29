import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { formatDistanceToNow } from 'date-fns';

interface Post {
  title: string;
  content: string;
  created_at: string;
  profiles: {
    username: string;
  };
  categories: {
    name: string;
  };
}

export default function PostDetail() {
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);
  const { slug } = useParams();

  useEffect(() => {
    if (slug) {
      fetchPost();
    }
  }, [slug]);

  async function fetchPost() {
    const { data, error } = await supabase
      .from('posts')
      .select(`
        title,
        content,
        created_at,
        profiles (username),
        categories (name)
      `)
      .eq('slug', slug)
      .eq('published', true)
      .single();

    if (!error && data) {
      setPost(data);
    }
    setLoading(false);
  }

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!post) {
    return <div>Post not found</div>;
  }

  return (
    <div className="max-w-4xl mx-auto">
      <article className="bg-white rounded-lg shadow-sm p-8">
        <h1 className="text-4xl font-bold mb-4">{post.title}</h1>
        <div className="text-sm text-gray-500 mb-8">
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
        <div 
          className="prose max-w-none"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />
      </article>
    </div>
  );
}