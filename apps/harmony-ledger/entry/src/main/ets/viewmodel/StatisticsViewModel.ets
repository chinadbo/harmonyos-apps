import { Category, DailyTrendPoint, PieChartItem } from '../data/DataModels';
import { TransactionRepo } from '../data/TransactionRepo';
import { CategoryRepo } from '../data/CategoryRepo';
import { DatabaseHelper } from '../data/DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';

export class StatisticsViewModel {
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  trendPoints: DailyTrendPoint[] = [];
  pieItems: PieChartItem[] = [];
  month: string = DateUtils.currentMonthKey();
  currency: string = '¥';

  async load(): Promise<void> {
    this.currency = await this.db.getCurrency();
    const categoryMap: Record<number, { name: string; color: string }> = {};
    const categories: Category[] = await this.categoryRepo.listAll();
    categories.forEach((item: Category) => {
      categoryMap[item.id] = { name: item.name, color: item.color };
    });
    this.trendPoints = await this.transactionRepo.getDailyTrend(30);
    this.pieItems = await this.transactionRepo.getExpensePie(this.month, categoryMap);
  }
}
