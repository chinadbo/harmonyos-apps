import { BackgroundOption, StickerItem } from '../models/StickerModel';

export const CANVAS_WIDTH: number = 320;
export const CANVAS_HEIGHT: number = 420;
export const MOVE_STEP: number = 12;
export const MIN_FONT_SIZE: number = 18;
export const MAX_FONT_SIZE: number = 48;
export const COLOR_OPTIONS: string[] = ['#FFFFFFFF', '#FF111827', '#FFE11D48', '#FF2563EB', '#FF059669', '#FFF59E0B'];
export const BACKGROUND_OPTIONS: BackgroundOption[] = [
  { id: 1, title: 'Classic Meme', colors: ['#FF111827', '#FF374151'], accent: '#FFFFFFFF' },
  { id: 2, title: 'Pop Party', colors: ['#FFF472B6', '#FFFB7185'], accent: '#FFFFFFFF' },
  { id: 3, title: 'Ocean Glow', colors: ['#FF0EA5E9', '#FF312E81'], accent: '#FFDBEAFE' }
];

export function createSticker(id: number, text: string, color: string): StickerItem {
  return {
    id,
    text,
    color,
    fontSize: 28,
    offsetX: 0,
    offsetY: 0
  };
}
