import { ToolType, ToolConfig, PRESET_COLORS } from '../models/Types';

export class ToolManager {
  private currentTool: ToolConfig = {
    type: ToolType.Pencil,
    size: 5,
    color: '#000000',
    opacity: 1.0
  };

  private listeners: ((tool: ToolConfig) => void)[] = [];

  getTool(): ToolConfig {
    return { ...this.currentTool };
  }

  setToolType(type: ToolType): void {
    this.currentTool.type = type;
    if (type === ToolType.Eraser) {
      this.currentTool.opacity = 1.0;
    } else if (type === ToolType.Highlighter) {
      this.currentTool.opacity = 0.5;
    } else {
      this.currentTool.opacity = 1.0;
    }
    this.notifyListeners();
  }

  setSize(size: number): void {
    this.currentTool.size = Math.max(1, Math.min(50, size));
    this.notifyListeners();
  }

  setColor(color: string): void {
    this.currentTool.color = color;
    this.notifyListeners();
  }

  setOpacity(opacity: number): void {
    this.currentTool.opacity = Math.max(0.1, Math.min(1.0, opacity));
    this.notifyListeners();
  }

  isShapeTool(): boolean {
    return this.currentTool.type === ToolType.Line ||
           this.currentTool.type === ToolType.Rectangle ||
           this.currentTool.type === ToolType.Circle ||
           this.currentTool.type === ToolType.Arrow;
  }

  onToolChange(callback: (tool: ToolConfig) => void): void {
    this.listeners.push(callback);
  }

  private notifyListeners(): void {
    for (const listener of this.listeners) {
      listener({ ...this.currentTool });
    }
  }
}
