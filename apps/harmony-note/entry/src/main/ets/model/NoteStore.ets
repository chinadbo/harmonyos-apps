import { Note, NoteIndexItem, Notebook, SearchResult, buildPreview, countWords, generateId } from './NoteModel';
import { NoteService } from './NoteService';

export class NoteStore {
  private static service: NoteService | null = null;

  static init(filesDir: string): void {
    if (!this.service) {
      this.service = new NoteService(filesDir);
      this.service.init();
    }

    const index = this.service.loadIndex();
    AppStorage.SetOrCreate('filesDir', filesDir);
    AppStorage.SetOrCreate('serviceReady', true);
    AppStorage.SetOrCreate('notebooks', index.notebooks);
    AppStorage.SetOrCreate('notes', index.notes);
    AppStorage.SetOrCreate('selectedNotebookId', index.notebooks.length > 0 ? index.notebooks[0].id : '');
    AppStorage.SetOrCreate('searchKeyword', '');
    AppStorage.SetOrCreate('searchResult', { keyword: '', items: [] } as SearchResult);
    AppStorage.SetOrCreate('lastError', '');
    AppStorage.SetOrCreate('homeRefreshFlag', 0);
  }

  static getService(): NoteService {
    const service = this.service;
    if (!service) {
      throw new Error('NoteStore has not been initialized');
    }
    return service;
  }

  static setError(message: string): void {
    AppStorage.SetOrCreate('lastError', message);
  }

  static clearError(): void {
    AppStorage.SetOrCreate('lastError', '');
  }

  static reload(): void {
    try {
      const index = this.getService().loadIndex();
      AppStorage.SetOrCreate('notebooks', index.notebooks);
      AppStorage.SetOrCreate('notes', index.notes);
      const currentNotebookId: string = AppStorage.Get('selectedNotebookId') as string || '';
      const hasCurrent = index.notebooks.some((item: Notebook) => item.id === currentNotebookId);
      if (!hasCurrent) {
        AppStorage.SetOrCreate('selectedNotebookId', index.notebooks.length > 0 ? index.notebooks[0].id : '');
      }
      const refreshFlag: number = AppStorage.Get('homeRefreshFlag') as number || 0;
      AppStorage.SetOrCreate('homeRefreshFlag', refreshFlag + 1);
      this.clearError();
    } catch (error) {
      const message = '刷新数据失败';
      console.error(message + ': ' + JSON.stringify(error));
      this.setError(message);
    }
  }

  static ensureDefaultNotebook(): Notebook {
    const notebooks: Notebook[] = (AppStorage.Get('notebooks') as Notebook[]) || [];
    if (notebooks.length > 0) {
      return notebooks[0];
    }
    const now = Date.now();
    const notebook: Notebook = {
      id: generateId('book'),
      name: '默认笔记本',
      description: '系统默认创建的分类',
      createdAt: now,
      updatedAt: now,
      noteCount: 0
    };
    try {
      this.getService().createNotebook(notebook);
      this.reload();
      AppStorage.SetOrCreate('selectedNotebookId', notebook.id);
      return notebook;
    } catch (error) {
      console.error('Failed to ensure default notebook: ' + JSON.stringify(error));
      this.setError('创建默认笔记本失败');
      return notebook;
    }
  }

  static createNotebook(name: string, description: string): Notebook {
    const now = Date.now();
    const notebook: Notebook = {
      id: generateId('book'),
      name: name.trim().length > 0 ? name.trim() : '未命名笔记本',
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
      noteCount: 0
    };
    try {
      this.getService().createNotebook(notebook);
      this.reload();
      AppStorage.SetOrCreate('selectedNotebookId', notebook.id);
    } catch (error) {
      console.error('Failed to create notebook: ' + JSON.stringify(error));
      this.setError('创建笔记本失败');
    }
    return notebook;
  }

  static updateNotebookCounts(): void {
    try {
      const service = this.getService();
      const index = service.loadIndex();
      const mapped: Notebook[] = index.notebooks.map((notebook: Notebook) => {
        const count = index.notes.filter((item: NoteIndexItem) => item.notebookId === notebook.id).length;
        return {
          ...notebook,
          noteCount: count,
          updatedAt: notebook.updatedAt
        };
      });
      service.saveIndex({
        notebooks: mapped,
        notes: index.notes
      });
      this.reload();
    } catch (error) {
      console.error('Failed to update notebook counts: ' + JSON.stringify(error));
      this.setError('更新分类统计失败');
    }
  }

  static saveNote(noteId: string, notebookId: string, title: string, content: string, isNew: boolean): Note {
    const targetNotebookId: string = notebookId || this.ensureDefaultNotebook().id;
    const now = Date.now();
    const currentContent: string = content;
    let createdAt: number = now;
    if (!isNew) {
      const existing = this.findNoteMeta(noteId);
      if (existing) {
        createdAt = existing.createdAt;
      }
    }
    const note: Note = {
      id: isNew ? generateId('note') : noteId,
      title: title.trim().length > 0 ? title.trim() : '未命名笔记',
      content: currentContent,
      notebookId: targetNotebookId,
      createdAt: createdAt,
      updatedAt: now,
      wordCount: countWords(currentContent),
      preview: buildPreview(currentContent)
    };
    try {
      this.getService().saveNote(note);
      this.updateNotebookTouchTime(note.notebookId, now);
      this.reload();
      this.updateNotebookCounts();
      this.clearError();
    } catch (error) {
      console.error('Failed to save note: ' + JSON.stringify(error));
      this.setError('保存笔记失败');
    }
    return note;
  }

  static deleteNote(noteId: string): void {
    try {
      this.getService().deleteNote(noteId);
      this.reload();
      this.updateNotebookCounts();
      this.clearError();
    } catch (error) {
      console.error('Failed to delete note: ' + JSON.stringify(error));
      this.setError('删除笔记失败');
    }
  }

  static search(keyword: string): NoteIndexItem[] {
    const value = keyword.trim();
    try {
      const result = value.length === 0 ? [] : this.getService().searchNotes(value);
      AppStorage.SetOrCreate('searchKeyword', value);
      AppStorage.SetOrCreate('searchResult', {
        keyword: value,
        items: result
      } as SearchResult);
      return result;
    } catch (error) {
      console.error('Failed to search notes: ' + JSON.stringify(error));
      this.setError('搜索笔记失败');
      return [];
    }
  }

  static loadNoteContent(noteId: string): string {
    try {
      return this.getService().loadNote(noteId);
    } catch (error) {
      console.error('Failed to load note content from store: ' + JSON.stringify(error));
      this.setError('读取笔记内容失败');
      return '';
    }
  }

  static findNoteMeta(noteId: string): NoteIndexItem | null {
    const notes: NoteIndexItem[] = (AppStorage.Get('notes') as NoteIndexItem[]) || [];
    const found = notes.find((item: NoteIndexItem) => item.id === noteId);
    return found ? found : null;
  }

  static getNotesByNotebook(notebookId: string): NoteIndexItem[] {
    const notes: NoteIndexItem[] = (AppStorage.Get('notes') as NoteIndexItem[]) || [];
    return notes
      .filter((item: NoteIndexItem) => item.notebookId === notebookId)
      .sort((a: NoteIndexItem, b: NoteIndexItem) => b.updatedAt - a.updatedAt);
  }

  static getNotebookById(notebookId: string): Notebook | null {
    const notebooks: Notebook[] = (AppStorage.Get('notebooks') as Notebook[]) || [];
    const found = notebooks.find((item: Notebook) => item.id === notebookId);
    return found ? found : null;
  }

  static getNoteCount(): number {
    const notes: NoteIndexItem[] = (AppStorage.Get('notes') as NoteIndexItem[]) || [];
    return notes.length;
  }

  static getNotebookCount(): number {
    const notebooks: Notebook[] = (AppStorage.Get('notebooks') as Notebook[]) || [];
    return notebooks.length;
  }

  private static updateNotebookTouchTime(notebookId: string, timestamp: number): void {
    try {
      const service = this.getService();
      const index = service.loadIndex();
      index.notebooks = index.notebooks.map((item: Notebook) => {
        if (item.id === notebookId) {
          return {
            ...item,
            updatedAt: timestamp
          };
        }
        return item;
      });
      service.saveIndex(index);
    } catch (error) {
      console.error('Failed to update notebook timestamp: ' + JSON.stringify(error));
      this.setError('更新分类时间失败');
    }
  }
}
