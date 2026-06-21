import { Poem } from '../model/Poem';

export class PoemDataSource implements IDataSource {
  private poems: Poem[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(poems: Poem[]) {
    this.poems = poems;
  }

  totalCount(): number {
    return this.poems.length;
  }

  getData(index: number): Poem {
    return this.poems[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  updatePoems(poems: Poem[]): void {
    this.poems = poems;
    this.notifyDataReload();
  }

  getAll(): Poem[] {
    return this.poems;
  }
}
