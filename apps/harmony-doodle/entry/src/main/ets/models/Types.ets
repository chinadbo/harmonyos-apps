export enum ToolType {
  Pencil = 0,
  Marker = 1,
  Eraser = 2,
  Highlighter = 3,
  Line = 4,
  Rectangle = 5,
  Circle = 6,
  Arrow = 7
}

export enum DrawingMode {
  Free = 0,
  Shape = 1
}

export interface Point {
  x: number;
  y: number;
}

export interface ToolConfig {
  type: ToolType;
  size: number;
  color: string;
  opacity: number;
}

export interface LayerInfo {
  id: number;
  name: string;
  visible: boolean;
  opacity: number;
  canvas: OffscreenCanvas | null;
  ctx: CanvasRenderingContext2D | null;
}

export interface ArtworkMeta {
  id: string;
  name: string;
  createdAt: number;
  width: number;
  height: number;
  filePath: string;
}

export interface DrawEvent {
  type: 'start' | 'move' | 'end';
  point: Point;
  tool: ToolConfig;
}

export const PRESET_COLORS: string[] = [
  '#000000', '#FFFFFF', '#FF0000', '#00FF00', '#0000FF',
  '#FFFF00', '#00FFFF', '#FF00FF', '#FFA500', '#800080',
  '#FFC0CB', '#A52A2A', '#808080', '#C0C0C0', '#FFD700',
  '#FF6347', '#40E0D0', '#EE82EE', '#98FB98', '#F0E68C'
];

export const TOOL_NAMES: string[] = [
  'Pencil', 'Marker', 'Eraser', 'Highlighter', 'Line', 'Rectangle', 'Circle', 'Arrow'
];
