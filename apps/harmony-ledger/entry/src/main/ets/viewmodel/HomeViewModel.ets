import { Category, MonthlySummary, Transaction, TransactionDataSource } from '../data/DataModels';
import { TransactionRepo } from '../data/TransactionRepo';
import { CategoryRepo } from '../data/CategoryRepo';
import { DatabaseHelper } from '../data/DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';

export class HomeViewModel {
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  dataSource: TransactionDataSource = new TransactionDataSource();
  transactions: Transaction[] = [];
  categories: Record<number, Category> = {};
  categoryList: Category[] = [];
  summary: MonthlySummary = {
    month: DateUtils.currentMonthKey(),
    income: 0,
    expense: 0,
    balance: 0,
    transactionCount: 0
  };
  currency: string = '¥';

  async load(): Promise<void> {
    this.currency = await this.db.getCurrency();
    const categoryList: Category[] = await this.categoryRepo.listAll();
    this.categoryList = categoryList;
    this.categories = {};
    categoryList.forEach((item: Category) => {
      this.categories[item.id] = item;
    });
    this.transactions = await this.transactionRepo.listRecent(100);
    this.dataSource.setData(this.transactions);
    this.summary = await this.transactionRepo.getMonthSummary(DateUtils.currentMonthKey());
  }
}
