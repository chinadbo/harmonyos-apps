/**
 * StatsModel.ets — 统计聚合数据模型
 */

/** 品类维度统计（环形图） */
export class CategoryStat {
  key: string = '';
  name: string = '';
  color: string = '#B0743B';
  count: number = 0;
  value: number = 0;
}

/** 成色维度统计（柱状图） */
export class ConditionStat {
  condition: string = '';
  color: string = '#B0743B';
  count: number = 0;
  value: number = 0;
}

/** 概览指标 */
export class StatsSummary {
  count: number = 0;
  totalCost: number = 0;
  totalValue: number = 0;
  gain: number = 0;
  imageCount: number = 0;

  gainRate(): number {
    if (this.totalCost <= 0) {
      return 0;
    }
    return (this.totalValue - this.totalCost) / this.totalCost;
  }
}

/** 统计结果 */
export class StatsResult {
  summary: StatsSummary = new StatsSummary();
  categories: CategoryStat[] = [];
  conditions: ConditionStat[] = [];
  topItems: string[] = [];
}
