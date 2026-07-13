import { image } from '@kit.ImageKit';
import { Layer } from './Layer';

export class HistoryManager {
  private history: ImageData[] = [];
  private historyIndex: number = -1;
  private maxHistory: number = 20;

  constructor(maxHistory: number = 20) {
    this.maxHistory = maxHistory;
  }

  saveSnapshot(layer: Layer): void {
    const snapshot = layer.getSnapshot();
    if (!snapshot) return;

    if (this.historyIndex < this.history.length - 1) {
      this.history = this.history.slice(0, this.historyIndex + 1);
    }

    this.history.push(snapshot);
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    } else {
      this.historyIndex++;
    }
  }

  canUndo(): boolean {
    return this.historyIndex > 0;
  }

  canRedo(): boolean {
    return this.historyIndex < this.history.length - 1;
  }

  undo(layer: Layer): boolean {
    if (!this.canUndo()) return false;
    this.historyIndex--;
    const snapshot = this.history[this.historyIndex];
    if (snapshot) {
      layer.restoreFromSnapshot(snapshot);
    }
    return true;
  }

  redo(layer: Layer): boolean {
    if (!this.canRedo()) return false;
    this.historyIndex++;
    const snapshot = this.history[this.historyIndex];
    if (snapshot) {
      layer.restoreFromSnapshot(snapshot);
    }
    return true;
  }

  clear(): void {
    this.history = [];
    this.historyIndex = -1;
  }

  initWithSnapshot(layer: Layer): void {
    this.clear();
    const snapshot = layer.getSnapshot();
    if (snapshot) {
      this.history.push(snapshot);
      this.historyIndex = 0;
    }
  }
}
