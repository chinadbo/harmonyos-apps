import relationalStore from '@ohos.data.relationalStore';
import { Budget, BudgetStatus, Category } from './DataModels';
import { DatabaseHelper } from './DatabaseHelper';
import { TransactionRepo } from './TransactionRepo';
import { CategoryRepo } from './CategoryRepo';
import { DateUtils } from '../utils/DateUtils';

export class BudgetRepo {
  private static instance: BudgetRepo = new BudgetRepo();
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();

  static getInstance(): BudgetRepo {
    return BudgetRepo.instance;
  }

  async listAll(): Promise<Budget[]> {
    return await this.db.listAllBudgets();
  }

  async listByMonth(month: string): Promise<Budget[]> {
    const items: Budget[] = await this.listAll();
    return items.filter((item: Budget) => item.month === month);
  }

  async upsert(categoryId: number, month: string, amount: number): Promise<void> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('budgets');
    predicates.equalTo('categoryId', categoryId).and().equalTo('month', month);
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id']);
    const exists: boolean = resultSet.goToFirstRow();
    const budgetId: number = exists ? resultSet.getLong(resultSet.getColumnIndex('id')) : 0;
    resultSet.close();
    if (exists) {
      const updatePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('budgets');
      updatePredicates.equalTo('id', budgetId);
      await store.update({ amount }, updatePredicates);
    } else {
      await store.insert('budgets', {
        categoryId,
        month,
        amount
      });
    }
  }

  async delete(id: number): Promise<void> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('budgets');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async getBudgetStatus(month: string = DateUtils.currentMonthKey()): Promise<BudgetStatus[]> {
    const budgets: Budget[] = await this.listByMonth(month);
    const categories: Record<number, Category> = await this.categoryRepo.getMap();
    const transactions = await this.transactionRepo.listByMonth(month);
    return budgets.map((budget: Budget) => {
      const spent: number = transactions.filter((item) => item.type === 'expense' && item.categoryId === budget.categoryId)
        .reduce((total, item) => total + item.amount, 0);
      const amount: number = budget.amount <= 0 ? 1 : budget.amount;
      const category: Category = categories[budget.categoryId] ?? {
        id: budget.categoryId,
        name: '未知分类',
        icon: '❓',
        color: '#BDBDBD',
        type: 'expense',
        isSystem: false,
        sortOrder: 999
      };
      return {
        budget,
        category,
        spent,
        remaining: budget.amount - spent,
        progress: spent / amount,
        overBudget: spent > budget.amount
      };
    }).sort((left: BudgetStatus, right: BudgetStatus) => right.progress - left.progress);
  }
}
