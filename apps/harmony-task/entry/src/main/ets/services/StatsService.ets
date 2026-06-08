import { TaskDatabase } from '../database/TaskDatabase';

export interface StatsData {
  todayCompleted: number;
  todayTotal: number;
  weekCompleted: number;
  weekTotal: number;
  monthCompleted: number;
  monthTotal: number;
  categoryDistribution: CategoryStat[];
  weeklyTrend: DailyCount[];
}

export interface CategoryStat {
  categoryId: number;
  categoryName: string;
  color: string;
  count: number;
}

export interface DailyCount {
  date: string; // MM-DD
  completed: number;
}

export class StatsService {
  private db: TaskDatabase;

  constructor() {
    this.db = TaskDatabase.getInstance();
  }

  async getStatsData(): Promise<StatsData> {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const endOfToday = startOfToday + 24 * 60 * 60 * 1000 - 1;

    // 本周起始（周一）
    const dayOfWeek = now.getDay() === 0 ? 6 : now.getDay() - 1;
    const startOfWeek = startOfToday - dayOfWeek * 24 * 60 * 60 * 1000;
    const endOfWeek = startOfWeek + 7 * 24 * 60 * 60 * 1000 - 1;

    // 本月起始
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999).getTime();

    const todayCompleted = await this.db.getCompletedCount(startOfToday, endOfToday);
    const todayTotal = await this.db.getTotalCount(startOfToday, endOfToday);
    const weekCompleted = await this.db.getCompletedCount(startOfWeek, endOfWeek);
    const weekTotal = await this.db.getTotalCount(startOfWeek, endOfWeek);
    const monthCompleted = await this.db.getCompletedCount(startOfMonth, endOfMonth);
    const monthTotal = await this.db.getTotalCount(startOfMonth, endOfMonth);

    const categoryDistribution = await this.getCategoryDistribution();
    const weeklyTrend = await this.getWeeklyTrend(startOfWeek);

    return {
      todayCompleted,
      todayTotal,
      weekCompleted,
      weekTotal,
      monthCompleted,
      monthTotal,
      categoryDistribution,
      weeklyTrend
    };
  }

  private async getCategoryDistribution(): Promise<CategoryStat[]> {
    const catCountMap = await this.db.getTaskCountByCategory();
    const categories = await this.db.queryAllCategories();
    const stats: CategoryStat[] = [];
    for (const cat of categories) {
      const count = catCountMap.get(cat.id!) || 0;
      if (count > 0) {
        stats.push({
          categoryId: cat.id!,
          categoryName: cat.name,
          color: cat.color,
          count: count
        });
      }
    }
    return stats;
  }

  private async getWeeklyTrend(startOfWeek: number): Promise<DailyCount[]> {
    const trend: DailyCount[] = [];
    for (let i = 0; i < 7; i++) {
      const dayStart = startOfWeek + i * 24 * 60 * 60 * 1000;
      const dayEnd = dayStart + 24 * 60 * 60 * 1000 - 1;
      const completed = await this.db.getCompletedCount(dayStart, dayEnd);
      const dateObj = new Date(dayStart);
      const dateStr = `${(dateObj.getMonth() + 1).toString().padStart(2, '0')}-${dateObj.getDate().toString().padStart(2, '0')}`;
      trend.push({ date: dateStr, completed });
    }
    return trend;
  }
}
