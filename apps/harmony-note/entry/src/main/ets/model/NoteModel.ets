export interface Notebook {
  id: string;
  name: string;
  description: string;
  createdAt: number;
  updatedAt: number;
  noteCount: number;
}

export interface Note {
  id: string;
  title: string;
  content: string;
  notebookId: string;
  createdAt: number;
  updatedAt: number;
  wordCount: number;
  preview: string;
}

export interface NoteIndexItem {
  id: string;
  title: string;
  notebookId: string;
  createdAt: number;
  updatedAt: number;
  wordCount: number;
  preview: string;
}

export interface NoteIndex {
  notebooks: Notebook[];
  notes: NoteIndexItem[];
}

export interface NoteListParam {
  notebookId: string;
  title: string;
}

export interface EditParam {
  noteId: string;
  notebookId: string;
  isNew: boolean;
}

export interface PreviewParam {
  noteId: string;
  title: string;
  content?: string;
}

export interface SearchResult {
  keyword: string;
  items: NoteIndexItem[];
}

export function generateId(prefix: string = 'note'): string {
  const now: number = Date.now();
  const random: string = Math.random().toString(36).slice(2, 10);
  return `${prefix}_${now}_${random}`;
}

export function buildPreview(content: string): string {
  const plain: string = content
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/[#>*`\-\[\]_]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  if (plain.length === 0) {
    return '暂无内容';
  }
  if (plain.length <= 80) {
    return plain;
  }
  return plain.slice(0, 80) + '...';
}

export function countWords(content: string): number {
  const trimmed: string = content.replace(/\s+/g, ' ').trim();
  if (trimmed.length === 0) {
    return 0;
  }
  return trimmed.length;
}

export function formatTime(timestamp: number): string {
  const date: Date = new Date(timestamp);
  const year: string = String(date.getFullYear());
  const month: string = String(date.getMonth() + 1).padStart(2, '0');
  const day: string = String(date.getDate()).padStart(2, '0');
  const hours: string = String(date.getHours()).padStart(2, '0');
  const minutes: string = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day} ${hours}:${minutes}`;
}

export function emptyIndex(): NoteIndex {
  return {
    notebooks: [],
    notes: []
  };
}
