import { POOL_STANDARD, POOL_CHAR, POOL_WEAPON } from './GachaModels';

export class PresetPoolSpec {
  name: string = '';
  poolType: number = 0;
  upName: string = '';
  isCurrent: boolean = false;

  constructor(name: string, poolType: number, upName: string, isCurrent: boolean) {
    this.name = name;
    this.poolType = poolType;
    this.upName = upName;
    this.isCurrent = isCurrent;
  }
}

export const PRESET_POOLS: PresetPoolSpec[] = [
  new PresetPoolSpec('群星阁·标准池', POOL_STANDARD, '', false),
  new PresetPoolSpec('皎月之约·角色UP', POOL_CHAR, '神里绫华', true),
  new PresetPoolSpec('星辉共鸣·角色UP', POOL_CHAR, '钟离', false),
  new PresetPoolSpec('苍穹之翼·角色UP', POOL_CHAR, '温迪', false),
  new PresetPoolSpec('锋芒之誓·武器池', POOL_WEAPON, '', false),
  new PresetPoolSpec('煌金之心·武器池', POOL_WEAPON, '若水', false)
];

export class DemoPull {
  poolIndex: number = 0;
  star: number = 3;
  itemName: string = '';
  pullNo: number = 0;
  dayOffset: number = 0;

  constructor(poolIndex: number, star: number, itemName: string, pullNo: number, dayOffset: number) {
    this.poolIndex = poolIndex;
    this.star = star;
    this.itemName = itemName;
    this.pullNo = pullNo;
    this.dayOffset = dayOffset;
  }
}

export const DEMO_PULLS: DemoPull[] = [
  new DemoPull(1, 3, '军粮便当', 0, 15),
  new DemoPull(1, 3, '幸运硬币', 0, 15),
  new DemoPull(1, 3, '砂金怀表', 0, 14),
  new DemoPull(1, 4, '祭礼残章', 0, 14),
  new DemoPull(1, 3, '泛黄信笺', 0, 13),
  new DemoPull(1, 3, '旅行者手记', 0, 12),
  new DemoPull(1, 3, '星屑矿石', 0, 11),
  new DemoPull(1, 3, '旧贵族徽章', 0, 10),
  new DemoPull(1, 5, '神里绫华', 78, 9),
  new DemoPull(1, 3, '铜质口哨', 0, 8),
  new DemoPull(1, 3, '野莓果酱', 0, 7),
  new DemoPull(1, 4, '笛剑', 0, 6),
  new DemoPull(1, 3, '灰烬残页', 0, 5),
  new DemoPull(1, 3, '漆黑羽翎', 0, 4),
  new DemoPull(1, 3, '无名残卷', 0, 3),
  new DemoPull(1, 4, '匣里龙吟', 0, 2),
  new DemoPull(0, 3, '砂金怀表', 0, 21),
  new DemoPull(0, 3, '泛黄信笺', 0, 20),
  new DemoPull(0, 4, '沉沙之钟', 0, 19),
  new DemoPull(0, 3, '星屑矿石', 0, 18),
  new DemoPull(0, 3, '铜质口哨', 0, 17),
  new DemoPull(0, 5, '刻晴', 32, 16),
  new DemoPull(0, 3, '灰烬残页', 0, 15),
  new DemoPull(0, 4, '祭礼弓', 0, 14),
  new DemoPull(4, 3, '星屑矿石', 0, 11),
  new DemoPull(4, 3, '漆黑羽翎', 0, 10),
  new DemoPull(4, 3, '旧贵族徽章', 0, 9),
  new DemoPull(4, 4, '弓·钢矢', 0, 8),
  new DemoPull(4, 3, '军粮便当', 0, 7),
  new DemoPull(4, 3, '泛黄信笺', 0, 6),
  new DemoPull(4, 4, '流浪乐章', 0, 5),
  new DemoPull(4, 3, '野莓果酱', 0, 4),
  new DemoPull(2, 3, '灰烬残页', 0, 6),
  new DemoPull(2, 3, '无名残卷', 0, 5),
  new DemoPull(2, 4, '祭礼残章', 0, 4),
  new DemoPull(2, 3, '幸运硬币', 0, 3),
  new DemoPull(3, 3, '旅行者手记', 0, 2),
  new DemoPull(3, 3, '星屑矿石', 0, 2),
  new DemoPull(5, 4, '西风剑', 0, 1),
  new DemoPull(5, 3, '铜质口哨', 0, 1)
];
