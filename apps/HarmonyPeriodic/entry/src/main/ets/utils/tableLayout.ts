export interface LayoutPosition {
  row: number;
  col: number;
}

export const TABLE_COLUMNS: number = 18;

// 主表 7 行之外，镧系/锕系分别位于第 9、10 行
export const LANTHANIDE_ROW: number = 9;
export const ACTINIDE_ROW: number = 10;

// 第 6/7 行第 3 列不放置真实元素，仅作为镧系/锕系占位标记
export const LANTHANIDE_PLACEHOLDER: LayoutPosition = { row: 6, col: 3 };
export const ACTINIDE_PLACEHOLDER: LayoutPosition = { row: 7, col: 3 };

export function getLayoutPosition(atomicNumber: number): LayoutPosition {
  if (atomicNumber >= 57 && atomicNumber <= 71) {
    return { row: LANTHANIDE_ROW, col: atomicNumber - 54 };
  }
  if (atomicNumber >= 89 && atomicNumber <= 103) {
    return { row: ACTINIDE_ROW, col: atomicNumber - 86 };
  }
  if (atomicNumber === 1) {
    return { row: 1, col: 1 };
  }
  if (atomicNumber === 2) {
    return { row: 1, col: 18 };
  }
  if (atomicNumber >= 3 && atomicNumber <= 4) {
    return { row: 2, col: atomicNumber - 2 };
  }
  if (atomicNumber >= 5 && atomicNumber <= 10) {
    return { row: 2, col: atomicNumber + 8 };
  }
  if (atomicNumber >= 11 && atomicNumber <= 12) {
    return { row: 3, col: atomicNumber - 10 };
  }
  if (atomicNumber >= 13 && atomicNumber <= 18) {
    return { row: 3, col: atomicNumber };
  }
  if (atomicNumber >= 19 && atomicNumber <= 36) {
    return { row: 4, col: atomicNumber - 18 };
  }
  if (atomicNumber >= 37 && atomicNumber <= 54) {
    return { row: 5, col: atomicNumber - 36 };
  }
  if (atomicNumber >= 55 && atomicNumber <= 56) {
    return { row: 6, col: atomicNumber - 54 };
  }
  if (atomicNumber >= 72 && atomicNumber <= 86) {
    return { row: 6, col: atomicNumber - 68 };
  }
  if (atomicNumber >= 87 && atomicNumber <= 88) {
    return { row: 7, col: atomicNumber - 86 };
  }
  if (atomicNumber >= 104 && atomicNumber <= 118) {
    return { row: 7, col: atomicNumber - 100 };
  }
  return { row: 0, col: 0 };
}
