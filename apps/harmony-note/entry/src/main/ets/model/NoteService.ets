import fs from '@ohos.file.fs';
import { Note, NoteIndex, NoteIndexItem, Notebook, emptyIndex } from './NoteModel';

export class NoteService {
  private filesDir: string;

  constructor(filesDir: string) {
    this.filesDir = filesDir;
  }

  init(): void {
    const notesDir = this.filesDir + '/notes';
    try {
      fs.accessSync(notesDir);
      // 目录存在，无需创建
    } catch (e) {
      // 目录不存在，创建它
      try {
        fs.mkdirSync(notesDir);
      } catch (mkErr) {
        console.error('Failed to create notes directory: ' + JSON.stringify(mkErr));
      }
    }

    const indexPath = this.filesDir + '/index.json';
    try {
      fs.accessSync(indexPath);
      // 文件存在，无需创建
    } catch (e) {
      // 文件不存在，创建初始 index
      try {
        fs.writeTextSync(indexPath, JSON.stringify(emptyIndex()));
      } catch (writeErr) {
        console.error('Failed to create index file: ' + JSON.stringify(writeErr));
      }
    }
  }

  loadIndex(): NoteIndex {
    try {
      const content = fs.readTextSync(this.filesDir + '/index.json');
      const parsed = JSON.parse(content) as NoteIndex;
      if (!parsed.notebooks || !parsed.notes) {
        return emptyIndex();
      }
      return parsed;
    } catch (error) {
      console.error('Failed to load index: ' + JSON.stringify(error));
      return emptyIndex();
    }
  }

  saveIndex(index: NoteIndex): void {
    const path = this.filesDir + '/index.json';
    const tmpPath = path + '.tmp';
    try {
      fs.writeTextSync(tmpPath, JSON.stringify(index));
      fs.renameSync(tmpPath, path);
    } catch (error) {
      console.error('Failed to save index: ' + JSON.stringify(error));
      try {
        if (fs.accessSync(tmpPath)) {
          fs.unlinkSync(tmpPath);
        }
      } catch (cleanupError) {
        console.error('Failed to cleanup temp index: ' + JSON.stringify(cleanupError));
      }
    }
  }

  saveNote(note: Note): void {
    const path = this.filesDir + '/notes/' + note.id + '.md';
    const tmpPath = path + '.tmp';
    try {
      fs.writeTextSync(tmpPath, note.content);
      fs.renameSync(tmpPath, path);
    } catch (error) {
      console.error('Failed to save note file: ' + JSON.stringify(error));
      try {
        if (fs.accessSync(tmpPath)) {
          fs.unlinkSync(tmpPath);
        }
      } catch (cleanupError) {
        console.error('Failed to cleanup temp note file: ' + JSON.stringify(cleanupError));
      }
      return;
    }

    const index = this.loadIndex();
    const idx = index.notes.findIndex((n: NoteIndexItem) => n.id === note.id);
    const item: NoteIndexItem = {
      id: note.id,
      title: note.title,
      notebookId: note.notebookId,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      wordCount: note.wordCount,
      preview: note.preview
    };
    if (idx >= 0) {
      index.notes[idx] = item;
    } else {
      index.notes.unshift(item);
    }
    this.saveIndex(index);
  }

  loadNote(id: string): string {
    try {
      return fs.readTextSync(this.filesDir + '/notes/' + id + '.md');
    } catch (error) {
      console.error('Failed to load note content: ' + JSON.stringify(error));
      return '';
    }
  }

  deleteNote(id: string): void {
    try {
      if (fs.accessSync(this.filesDir + '/notes/' + id + '.md')) {
        fs.unlinkSync(this.filesDir + '/notes/' + id + '.md');
      }
    } catch (error) {
      console.error('Failed to delete note file: ' + JSON.stringify(error));
    }
    const index = this.loadIndex();
    index.notes = index.notes.filter((n: NoteIndexItem) => n.id !== id);
    this.saveIndex(index);
  }

  createNotebook(notebook: Notebook): void {
    const index = this.loadIndex();
    const exist = index.notebooks.findIndex((item: Notebook) => item.id === notebook.id);
    if (exist >= 0) {
      index.notebooks[exist] = notebook;
    } else {
      index.notebooks.unshift(notebook);
    }
    this.saveIndex(index);
  }

  deleteNotebook(notebookId: string): void {
    const index = this.loadIndex();
    const noteIds: string[] = index.notes
      .filter((item: NoteIndexItem) => item.notebookId === notebookId)
      .map((item: NoteIndexItem) => item.id);
    for (const noteId of noteIds) {
      try {
        if (fs.accessSync(this.filesDir + '/notes/' + noteId + '.md')) {
          fs.unlinkSync(this.filesDir + '/notes/' + noteId + '.md');
        }
      } catch (error) {
        console.error('Failed to delete notebook note file: ' + JSON.stringify(error));
      }
    }
    index.notes = index.notes.filter((item: NoteIndexItem) => item.notebookId !== notebookId);
    index.notebooks = index.notebooks.filter((item: Notebook) => item.id !== notebookId);
    this.saveIndex(index);
  }

  searchNotes(keyword: string): NoteIndexItem[] {
    const index = this.loadIndex();
    const kw = keyword.toLowerCase();
    return index.notes.filter((n: NoteIndexItem) =>
      n.title.toLowerCase().includes(kw) ||
      n.preview.toLowerCase().includes(kw)
    );
  }

  getNotesByNotebook(notebookId: string): NoteIndexItem[] {
    const index = this.loadIndex();
    return index.notes
      .filter((item: NoteIndexItem) => item.notebookId === notebookId)
      .sort((a: NoteIndexItem, b: NoteIndexItem) => b.updatedAt - a.updatedAt);
  }

  getNotebookById(notebookId: string): Notebook | null {
    const index = this.loadIndex();
    const item = index.notebooks.find((notebook: Notebook) => notebook.id === notebookId);
    return item ? item : null;
  }

  listNotebooks(): Notebook[] {
    const index = this.loadIndex();
    return [...index.notebooks].sort((a: Notebook, b: Notebook) => b.updatedAt - a.updatedAt);
  }

  listNotes(): NoteIndexItem[] {
    const index = this.loadIndex();
    return [...index.notes].sort((a: NoteIndexItem, b: NoteIndexItem) => b.updatedAt - a.updatedAt);
  }
}
