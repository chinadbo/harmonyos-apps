import { ToolType, DrawingMode, Point, ToolConfig } from '../models/Types';

export class Layer {
  private canvas: OffscreenCanvas | null = null;
  private ctx: CanvasRenderingContext2D | null = null;
  id: number;
  name: string;
  visible: boolean = true;
  opacity: number = 1.0;

  constructor(id: number, name: string, width: number, height: number) {
    this.id = id;
    this.name = name;
    this.canvas = new OffscreenCanvas(width, height);
    this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;
    if (this.ctx) {
      this.ctx.lineCap = 'round';
      this.ctx.lineJoin = 'round';
    }
  }

  getCanvas(): OffscreenCanvas | null {
    return this.canvas;
  }

  getContext(): CanvasRenderingContext2D | null {
    return this.ctx;
  }

  clear(): void {
    if (this.ctx && this.canvas) {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
  }

  resize(width: number, height: number): void {
    const oldCanvas = this.canvas;
    this.canvas = new OffscreenCanvas(width, height);
    this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;
    if (this.ctx && oldCanvas) {
      this.ctx.drawImage(oldCanvas, 0, 0);
      this.ctx.lineCap = 'round';
      this.ctx.lineJoin = 'round';
    }
  }

  getSnapshot(): ImageData | null {
    if (this.ctx && this.canvas) {
      return this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);
    }
    return null;
  }

  restoreFromSnapshot(data: ImageData): void {
    if (this.ctx) {
      this.ctx.putImageData(data, 0, 0);
    }
  }
}
