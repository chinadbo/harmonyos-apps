/**
 * StatsService.ets — 统计聚合：概览 + 品类分布 + 成色分布
 */
import { CollectItem } from '../model/CollectItem';
import { Category } from '../model/Category';
import { ItemDao, CategoryDao } from '../model/Db';
import { CategoryStat, ConditionStat, StatsResult, StatsSummary } from '../model/StatsModel';
import { CONDITIONS, categoryColor, conditionColor } from '../common/Constants';
import { Logger } from '../common/Logger';

const TAG: string = 'StatsService';

export class StatsService {
  static async build(): Promise<StatsResult> {
    const result = new StatsResult();
    try {
      const items: CollectItem[] = await ItemDao.queryAll();
      const categories: Category[] = await CategoryDao.queryAll();
      result.summary = StatsService.summarize(items);
      result.categories = StatsService.groupByCategory(items, categories);
      result.conditions = StatsService.groupByCondition(items);
      result.topItems = StatsService.topItemNames(items);
    } catch (err) {
      Logger.error(TAG, 'build failed: ' + JSON.stringify(err));
    }
    return result;
  }

  static summarize(items: CollectItem[]): StatsSummary {
    const summary = new StatsSummary();
    summary.count = items.length;
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      summary.totalCost += it.acquirePrice;
      summary.totalValue += it.estValue;
      if (it.imageUri.length > 0) {
        summary.imageCount++;
      }
    }
    summary.gain = summary.totalValue - summary.totalCost;
    return summary;
  }

  static groupByCategory(items: CollectItem[], categories: Category[]): CategoryStat[] {
    const stats: CategoryStat[] = [];
    const index: Map<string, number> = new Map<string, number>();
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      const key: string = it.category.length > 0 ? it.category : 'other';
      if (!index.has(key)) {
        const stat = new CategoryStat();
        stat.key = key;
        stat.name = CategoryDao.nameOf(categories, key);
        stat.color = categoryColor(key);
        stat.count = 0;
        stat.value = 0;
        index.set(key, stats.length);
        stats.push(stat);
      }
      const pos: number = index.get(key) ?? -1;
      if (pos >= 0) {
        stats[pos].count += 1;
        stats[pos].value += it.estValue;
      }
    }
    stats.sort((a: CategoryStat, b: CategoryStat) => b.value - a.value);
    return stats;
  }

  static groupByCondition(items: CollectItem[]): ConditionStat[] {
    const stats: ConditionStat[] = [];
    const index: Map<string, number> = new Map<string, number>();
    for (let i = 0; i < CONDITIONS.length; i++) {
      const stat = new ConditionStat();
      stat.condition = CONDITIONS[i];
      stat.color = conditionColor(CONDITIONS[i]);
      stat.count = 0;
      stat.value = 0;
      index.set(CONDITIONS[i], stats.length);
      stats.push(stat);
    }
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      let pos: number = index.get(it.condition) ?? -1;
      if (pos < 0) {
        const stat = new ConditionStat();
        stat.condition = it.condition.length > 0 ? it.condition : '其他';
        stat.color = conditionColor(it.condition);
        stat.count = 0;
        stat.value = 0;
        pos = stats.length;
        stats.push(stat);
      }
      stats[pos].count += 1;
      stats[pos].value += it.estValue;
    }
    return stats;
  }

  static topItemNames(items: CollectItem[]): string[] {
    const sorted: CollectItem[] = items.slice();
    sorted.sort((a: CollectItem, b: CollectItem) => b.estValue - a.estValue);
    const names: string[] = [];
    const limit: number = sorted.length < 5 ? sorted.length : 5;
    for (let i = 0; i < limit; i++) {
      if (sorted[i].estValue > 0) {
        names.push(sorted[i].name);
      }
    }
    return names;
  }
}
