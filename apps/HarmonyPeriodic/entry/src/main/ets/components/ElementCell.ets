import { Element, getCategoryColor } from '../model/Element';

export const CELL_WIDTH: number = 54;
export const CELL_HEIGHT: number = 58;

const STATE_GAS_COLOR: string = '#D0BCFF';
const STATE_LIQUID_COLOR: string = '#A8DAB5';
const STATE_SOLID_COLOR: string = '#A7C7F9';

const BLOCK_S_COLOR: string = '#F28B82';
const BLOCK_P_COLOR: string = '#FBBC04';
const BLOCK_D_COLOR: string = '#B7E1CD';
const BLOCK_F_COLOR: string = '#E6C9A8';
const BLOCK_FALLBACK_COLOR: string = '#B9C4D4';

export function getElementColor(element: Element, colorScheme: string): string {
  if (colorScheme === 'state') {
    if (element.state === 'gas') {
      return STATE_GAS_COLOR;
    }
    if (element.state === 'liquid') {
      return STATE_LIQUID_COLOR;
    }
    return STATE_SOLID_COLOR;
  }
  if (colorScheme === 'block') {
    if (element.block === 's') {
      return BLOCK_S_COLOR;
    }
    if (element.block === 'p') {
      return BLOCK_P_COLOR;
    }
    if (element.block === 'd') {
      return BLOCK_D_COLOR;
    }
    if (element.block === 'f') {
      return BLOCK_F_COLOR;
    }
    return BLOCK_FALLBACK_COLOR;
  }
  return getCategoryColor(element.category);
}

@Component
export struct ElementCell {
  @Prop element: Element;
  @Prop colorScheme: string = 'category';
  @Prop dimmed: boolean = false;

  build() {
    Column() {
      Text(this.element.atomicNumber.toString())
        .fontSize(9)
        .fontColor('#B3000000')
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 4 })
      Text(this.element.symbol)
        .fontSize(this.element.symbol.length > 2 ? 13 : 17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E6000000')
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxLines(1)
      Text(this.element.nameZh)
        .fontSize(10)
        .fontColor('#CC000000')
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(CELL_WIDTH)
    .height(CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(getElementColor(this.element, this.colorScheme))
    .borderRadius(6)
    .border({ width: 0.5, color: '#26000000' })
    .opacity(this.dimmed ? 0.15 : 1)
  }
}
