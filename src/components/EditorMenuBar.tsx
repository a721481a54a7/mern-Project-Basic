import React from 'react';
import { Editor } from '@tiptap/react';
import { 
  Bold, Italic, List, ListOrdered, Link as LinkIcon, 
  Image as ImageIcon 
} from 'lucide-react';

interface EditorMenuBarProps {
  editor: Editor;
}

export default function EditorMenuBar({ editor }: EditorMenuBarProps) {
  return (
    <div className="border-b border-gray-200 p-2 flex gap-2">
      <button
        onClick={() => editor.chain().focus().toggleBold().run()}
        className={`p-2 rounded hover:bg-gray-100 ${
          editor.isActive('bold') ? 'bg-gray-100' : ''
        }`}
      >
        <Bold className="h-5 w-5" />
      </button>
      <button
        onClick={() => editor.chain().focus().toggleItalic().run()}
        className={`p-2 rounded hover:bg-gray-100 ${
          editor.isActive('italic') ? 'bg-gray-100' : ''
        }`}
      >
        <Italic className="h-5 w-5" />
      </button>
      <button
        onClick={() => editor.chain().focus().toggleBulletList().run()}
        className={`p-2 rounded hover:bg-gray-100 ${
          editor.isActive('bulletList') ? 'bg-gray-100' : ''
        }`}
      >
        <List className="h-5 w-5" />
      </button>
      <button
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
        className={`p-2 rounded hover:bg-gray-100 ${
          editor.isActive('orderedList') ? 'bg-gray-100' : ''
        }`}
      >
        <ListOrdered className="h-5 w-5" />
      </button>
      <button
        onClick={() => {
          const url = window.prompt('Enter the URL');
          if (url) {
            editor.chain().focus().setLink({ href: url }).run();
          }
        }}
        className={`p-2 rounded hover:bg-gray-100 ${
          editor.isActive('link') ? 'bg-gray-100' : ''
        }`}
      >
        <LinkIcon className="h-5 w-5" />
      </button>
      <button
        onClick={() => {
          const url = window.prompt('Enter the image URL');
          if (url) {
            editor.chain().focus().setImage({ src: url }).run();
          }
        }}
        className="p-2 rounded hover:bg-gray-100"
      >
        <ImageIcon className="h-5 w-5" />
      </button>
    </div>
  );
}