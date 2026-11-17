import util from '@ohos.util';
import common from '@ohos.app.ability.common';

export interface ElementRaw {
  atomicNumber: number;
  symbol: string;
  nameZh: string;
  nameEn: string;
  atomicMass: number;
  period: number;
  group: number;
  category: string;
  block: string;
  electronConfig: string;
  state: string;
  density: number;
  meltingPoint: number | null;
  boilingPoint: number | null;
  discoveredYear: number | null;
  usage: string;
}

interface ElementsFileRaw {
  elements: ElementRaw[];
}

export class Element {
  atomicNumber: number;
  symbol: string;
  nameZh: string;
  nameEn: string;
  atomicMass: number;
  period: number;
  group: number;
  category: string;
  block: string;
  electronConfig: string;
  state: string;
  density: number;
  meltingPoint: number | null;
  boilingPoint: number | null;
  discoveredYear: number | null;
  usage: string;

  constructor(raw: ElementRaw) {
    this.atomicNumber = raw.atomicNumber;
    this.symbol = raw.symbol;
    this.nameZh = raw.nameZh;
    this.nameEn = raw.nameEn;
    this.atomicMass = raw.atomicMass;
    this.period = raw.period;
    this.group = raw.group;
    this.category = raw.category;
    this.block = raw.block;
    this.electronConfig = raw.electronConfig;
    this.state = raw.state;
    this.density = raw.density;
    this.meltingPoint = raw.meltingPoint;
    this.boilingPoint = raw.boilingPoint;
    this.discoveredYear = raw.discoveredYear;
    this.usage = raw.usage;
  }

  getColor(): string {
    return getCategoryColor(this.category);
  }
}

export const FALLBACK_COLOR: string = '#B9C4D4';

function buildCategoryColors(): Map<string, string> {
  const colors = new Map<string, string>();
  colors.set('alkali-metal', '#F28B82');
  colors.set('alkaline-earth', '#FBBC04');
  colors.set('transition', '#A7C7F9');
  colors.set('post-transition', '#B9C4D4');
  colors.set('metalloid', '#A8DAB5');
  colors.set('nonmetal', '#CEEAD6');
  colors.set('halogen', '#FDCFE8');
  colors.set('noble-gas', '#D0BCFF');
  colors.set('lanthanide', '#E6C9A8');
  colors.set('actinide', '#DDBEA9');
  return colors;
}

export const CATEGORY_COLORS: Map<string, string> = buildCategoryColors();

export function getCategoryColor(category: string): string {
  const color = CATEGORY_COLORS.get(category);
  return color === undefined ? FALLBACK_COLOR : color;
}

export async function loadElements(context: common.Context): Promise<Element[]> {
  const bytes: Uint8Array = await context.resourceManager.getRawFileContent('elements.json');
  const decoder: util.TextDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
  const jsonText: string = decoder.decodeToString(bytes);
  const payload: ElementsFileRaw = JSON.parse(jsonText) as ElementsFileRaw;

  const elements: Element[] = [];
  for (const raw of payload.elements) {
    elements.push(new Element(raw));
  }
  elements.sort((a: Element, b: Element): number => a.atomicNumber - b.atomicNumber);
  return elements;
}
