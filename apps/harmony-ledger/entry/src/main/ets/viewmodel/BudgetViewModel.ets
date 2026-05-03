import { BudgetStatus, Category } from '../data/DataModels';
import { BudgetRepo } from '../data/BudgetRepo';
import { CategoryRepo } from '../data/CategoryRepo';
import { DatabaseHelper } from '../data/DatabaseHelper';
import { NotificationHelper } from '../utils/NotificationHelper';
import { DateUtils } from '../utils/DateUtils';

export class BudgetViewModel {
  private budgetRepo: BudgetRepo = BudgetRepo.getInstance();
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  statuses: BudgetStatus[] = [];
  categories: Category[] = [];
  month: string = DateUtils.currentMonthKey();
  currency: string = '¥';

  async load(): Promise<void> {
    this.currency = await this.db.getCurrency();
    this.categories = await this.categoryRepo.listForType('expense');
    this.statuses = await this.budgetRepo.getBudgetStatus(this.month);
    for (const status of this.statuses) {
      await NotificationHelper.notifyBudgetExceeded(status, this.currency);
    }
  }

  async saveBudget(categoryId: number, amount: number): Promise<void> {
    await this.budgetRepo.upsert(categoryId, this.month, amount);
    await this.load();
  }
}
