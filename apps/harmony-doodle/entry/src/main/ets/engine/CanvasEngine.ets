import { ToolType, DrawingMode, Point, ToolConfig } from '../models/Types';
import { Layer } from './Layer';
import { HistoryManager } from './HistoryManager';

export class CanvasEngine {
  private layers: Layer[] = [];
  private activeLayerIndex: number = 0;
  private historyManagers: Map<number, HistoryManager> = new Map();
  private width: number = 1080;
  private height: number = 1920;
  private isDrawing: boolean = false;
  private lastPoint: Point | null = null;
  private startPoint: Point | null = null;
  private previewCanvas: OffscreenCanvas | null = null;
  private previewCtx: CanvasRenderingContext2D | null = null;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
    this.previewCanvas = new OffscreenCanvas(width, height);
    this.previewCtx = this.previewCanvas.getContext('2d') as CanvasRenderingContext2D;
    if (this.previewCtx) {
      this.previewCtx.lineCap = 'round';
      this.previewCtx.lineJoin = 'round';
    }
    this.addLayer('Layer 1');
  }

  addLayer(name: string): number {
    const id = this.layers.length;
    const layer = new Layer(id, name, this.width, this.height);
    this.layers.push(layer);
    this.historyManagers.set(id, new HistoryManager(20));
    this.historyManagers.get(id)?.initWithSnapshot(layer);
    this.activeLayerIndex = id;
    return id;
  }

  deleteLayer(index: number): boolean {
    if (this.layers.length <= 1 || index < 0 || index >= this.layers.length) return false;
    this.layers.splice(index, 1);
    this.historyManagers.delete(index);
    if (this.activeLayerIndex >= this.layers.length) {
      this.activeLayerIndex = this.layers.length - 1;
    }
    return true;
  }

  getLayers(): Layer[] {
    return this.layers;
  }

  setActiveLayer(index: number): void {
    if (index >= 0 && index < this.layers.length) {
      this.activeLayerIndex = index;
    }
  }

  getActiveLayer(): Layer | null {
    if (this.activeLayerIndex >= 0 && this.activeLayerIndex < this.layers.length) {
      return this.layers[this.activeLayerIndex];
    }
    return null;
  }

  getActiveLayerIndex(): number {
    return this.activeLayerIndex;
  }

  onTouchStart(point: Point, tool: ToolConfig): void {
    this.isDrawing = true;
    this.startPoint = point;
    this.lastPoint = point;

    const layer = this.getActiveLayer();
    if (!layer) return;

    const historyManager = this.historyManagers.get(layer.id);
    if (historyManager) {
      historyManager.saveSnapshot(layer);
    }

    const ctx = layer.getContext();
    if (!ctx) return;

    this.setupContext(ctx, tool);

    if (tool.type === ToolType.Eraser) {
      ctx.globalCompositeOperation = 'destination-out';
    }

    ctx.beginPath();
    ctx.moveTo(point.x, point.y);
  }

  onTouchMove(point: Point, tool: ToolConfig): void {
    if (!this.isDrawing || !this.lastPoint) return;

    const layer = this.getActiveLayer();
    if (!layer) return;
    const ctx = layer.getContext();
    if (!ctx) return;

    if (tool.type === ToolType.Line || tool.type === ToolType.Rectangle ||
        tool.type === ToolType.Circle || tool.type === ToolType.Arrow) {
      this.drawPreviewShape(point, tool);
      return;
    }

    this.setupContext(ctx, tool);
    if (tool.type === ToolType.Eraser) {
      ctx.globalCompositeOperation = 'destination-out';
    }

    ctx.lineTo(point.x, point.y);
    ctx.stroke();

    this.lastPoint = point;
  }

  onTouchEnd(point: Point, tool: ToolConfig): void {
    if (!this.isDrawing) return;
    this.isDrawing = false;

    const layer = this.getActiveLayer();
    if (!layer) return;
    const ctx = layer.getContext();
    if (!ctx) return;

    if (tool.type === ToolType.Line || tool.type === ToolType.Rectangle ||
        tool.type === ToolType.Circle || tool.type === ToolType.Arrow) {
      if (this.startPoint) {
        this.setupContext(ctx, tool);
        this.drawShape(ctx, this.startPoint, point, tool);
      }
      this.clearPreview();
    } else {
      ctx.closePath();
    }

    ctx.globalCompositeOperation = 'source-over';
    this.lastPoint = null;
    this.startPoint = null;
  }

  private setupContext(ctx: CanvasRenderingContext2D, tool: ToolConfig): void {
    ctx.lineWidth = tool.size;
    ctx.strokeStyle = tool.color;
    ctx.fillStyle = tool.color;
    ctx.globalAlpha = tool.opacity;
    ctx.globalCompositeOperation = 'source-over';
    if (tool.type === ToolType.Marker) {
      ctx.lineCap = 'square';
    } else {
      ctx.lineCap = 'round';
    }
    ctx.lineJoin = 'round';
  }

  private drawPreviewShape(endPoint: Point, tool: ToolConfig): void {
    if (!this.previewCtx || !this.startPoint) return;
    this.previewCtx.clearRect(0, 0, this.width, this.height);
    this.setupContext(this.previewCtx, tool);
    this.drawShape(this.previewCtx, this.startPoint, endPoint, tool);
  }

  private drawShape(ctx: CanvasRenderingContext2D, start: Point, end: Point, tool: ToolConfig): void {
    ctx.beginPath();
    switch (tool.type) {
      case ToolType.Line:
        ctx.moveTo(start.x, start.y);
        ctx.lineTo(end.x, end.y);
        ctx.stroke();
        break;
      case ToolType.Rectangle:
        const rx = Math.min(start.x, end.x);
        const ry = Math.min(start.y, end.y);
        const rw = Math.abs(end.x - start.x);
        const rh = Math.abs(end.y - start.y);
        ctx.strokeRect(rx, ry, rw, rh);
        break;
      case ToolType.Circle:
        const cx = (start.x + end.x) / 2;
        const cy = (start.y + end.y) / 2;
        const radius = Math.sqrt(Math.pow(end.x - start.x, 2) + Math.pow(end.y - start.y, 2)) / 2;
        ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
        ctx.stroke();
        break;
      case ToolType.Arrow:
        this.drawArrow(ctx, start, end);
        break;
    }
  }

  private drawArrow(ctx: CanvasRenderingContext2D, start: Point, end: Point): void {
    ctx.moveTo(start.x, start.y);
    ctx.lineTo(end.x, end.y);
    ctx.stroke();

    const angle = Math.atan2(end.y - start.y, end.x - start.x);
    const arrowLength = 15;
    const arrowAngle = Math.PI / 6;

    ctx.beginPath();
    ctx.moveTo(end.x, end.y);
    ctx.lineTo(
      end.x - arrowLength * Math.cos(angle - arrowAngle),
      end.y - arrowLength * Math.sin(angle - arrowAngle)
    );
    ctx.moveTo(end.x, end.y);
    ctx.lineTo(
      end.x - arrowLength * Math.cos(angle + arrowAngle),
      end.y - arrowLength * Math.sin(angle + arrowAngle)
    );
    ctx.stroke();
  }

  private clearPreview(): void {
    if (this.previewCtx) {
      this.previewCtx.clearRect(0, 0, this.width, this.height);
    }
  }

  renderToContext(ctx: CanvasRenderingContext2D): void {
    ctx.clearRect(0, 0, this.width, this.height);
    for (const layer of this.layers) {
      if (!layer.visible) continue;
      const canvas = layer.getCanvas();
      if (!canvas) continue;
      ctx.save();
      ctx.globalAlpha = layer.opacity;
      ctx.drawImage(canvas, 0, 0);
      ctx.restore();
    }
    if (this.previewCanvas) {
      ctx.drawImage(this.previewCanvas, 0, 0);
    }
  }

  undo(): boolean {
    const layer = this.getActiveLayer();
    if (!layer) return false;
    const historyManager = this.historyManagers.get(layer.id);
    if (!historyManager) return false;
    return historyManager.undo(layer);
  }

  redo(): boolean {
    const layer = this.getActiveLayer();
    if (!layer) return false;
    const historyManager = this.historyManagers.get(layer.id);
    if (!historyManager) return false;
    return historyManager.redo(layer);
  }

  canUndo(): boolean {
    const layer = this.getActiveLayer();
    if (!layer) return false;
    const historyManager = this.historyManagers.get(layer.id);
    return historyManager?.canUndo() ?? false;
  }

  canRedo(): boolean {
    const layer = this.getActiveLayer();
    if (!layer) return false;
    const historyManager = this.historyManagers.get(layer.id);
    return historyManager?.canRedo() ?? false;
  }

  clearCanvas(): void {
    const layer = this.getActiveLayer();
    if (!layer) return;
    const historyManager = this.historyManagers.get(layer.id);
    if (historyManager) {
      historyManager.saveSnapshot(layer);
    }
    layer.clear();
  }

  exportToImage(): ImageData | null {
    const exportCanvas = new OffscreenCanvas(this.width, this.height);
    const exportCtx = exportCanvas.getContext('2d') as CanvasRenderingContext2D;
    if (!exportCtx) return null;
    this.renderToContext(exportCtx);
    return exportCtx.getImageData(0, 0, this.width, this.height);
  }

  getExportCanvas(): OffscreenCanvas | null {
    const exportCanvas = new OffscreenCanvas(this.width, this.height);
    const exportCtx = exportCanvas.getContext('2d') as CanvasRenderingContext2D;
    if (!exportCtx) return null;
    this.renderToContext(exportCtx);
    return exportCanvas;
  }

  resize(width: number, height: number): void {
    this.width = width;
    this.height = height;
    if (this.previewCanvas) {
      this.previewCanvas = new OffscreenCanvas(width, height);
      this.previewCtx = this.previewCanvas.getContext('2d') as CanvasRenderingContext2D;
      if (this.previewCtx) {
        this.previewCtx.lineCap = 'round';
        this.previewCtx.lineJoin = 'round';
      }
    }
    for (const layer of this.layers) {
      layer.resize(width, height);
    }
  }
}
