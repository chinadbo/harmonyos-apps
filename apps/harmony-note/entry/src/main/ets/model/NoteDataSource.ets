import { NoteIndexItem } from './NoteModel';

export class NoteDataSource implements IDataSource {
  private notes: NoteIndexItem[] = [];
  private listeners: DataChangeListener[] = [];

  setData(notes: NoteIndexItem[]): void {
    this.notes = [...notes];
  }

  totalCount(): number {
    return this.notes.length;
  }

  getData(index: number): NoteIndexItem {
    return this.notes[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataAdd(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataDelete(index));
  }

  pushFront(item: NoteIndexItem): void {
    this.notes.unshift(item);
    this.notifyDataAdd(0);
  }

  removeById(id: string): void {
    const index = this.notes.findIndex((item: NoteIndexItem) => item.id === id);
    if (index >= 0) {
      this.notes.splice(index, 1);
      this.notifyDataDelete(index);
    }
  }

  replaceAll(notes: NoteIndexItem[]): void {
    this.notes = [...notes];
    this.notifyDataReload();
  }
}
