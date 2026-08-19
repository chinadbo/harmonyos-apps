export interface StickerItem {
  id: number;
  text: string;
  color: string;
  fontSize: number;
  offsetX: number;
  offsetY: number;
}

export interface BackgroundOption {
  id: number;
  title: string;
  colors: string[];
  accent: string;
}
