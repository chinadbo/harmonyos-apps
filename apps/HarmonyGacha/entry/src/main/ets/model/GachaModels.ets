export const STAR_GOLD: number = 5;
export const STAR_PURPLE: number = 4;
export const STAR_BLUE: number = 3;

export const POOL_STANDARD: number = 0;
export const POOL_CHAR: number = 1;
export const POOL_WEAPON: number = 2;
export const POOL_CUSTOM: number = 3;

export function poolTypeLabel(poolType: number): string {
  if (poolType === POOL_STANDARD) {
    return '标准池';
  }
  if (poolType === POOL_CHAR) {
    return '角色UP';
  }
  if (poolType === POOL_WEAPON) {
    return '武器池';
  }
  return '自定义';
}

export function starLabel(star: number): string {
  if (star === STAR_GOLD) {
    return '★5 金';
  }
  if (star === STAR_PURPLE) {
    return '★4 紫';
  }
  return '★3 蓝';
}

export class GachaRecord {
  id: number = 0;
  poolId: number = 0;
  star: number = STAR_BLUE;
  itemName: string = '';
  pullNo: number = 0;
  recordDate: string = '';
  createdAt: number = 0;
}

export class GachaPool {
  id: number = 0;
  name: string = '';
  poolType: number = POOL_CUSTOM;
  upName: string = '';
  startDate: string = '';
  endDate: string = '';
  isCurrent: boolean = false;
  builtin: boolean = false;
}

export class DayGroup {
  date: string = '';
  items: GachaRecord[] = [];
}

export class PoolShare {
  poolId: number = 0;
  name: string = '';
  goldCount: number = 0;
  totalCount: number = 0;
  percent: number = 0;
}

export class Summary {
  totalPulls: number = 0;
  goldCount: number = 0;
  purpleCount: number = 0;
  luckIndex: number = -1;
  avgGoldPulls: number = 0;
}
