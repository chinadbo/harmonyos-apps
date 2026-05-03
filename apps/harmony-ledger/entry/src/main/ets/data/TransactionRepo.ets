import relationalStore from '@ohos.data.relationalStore';
import { DailyTrendPoint, MonthlySummary, PieChartItem, Transaction } from './DataModels';
import { DatabaseHelper } from './DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';

export class TransactionRepo {
  private static instance: TransactionRepo = new TransactionRepo();
  private db: DatabaseHelper = DatabaseHelper.getInstance();

  static getInstance(): TransactionRepo {
    return TransactionRepo.instance;
  }

  async listAll(): Promise<Transaction[]> {
    return await this.db.listAllTransactions();
  }

  async listRecent(limit: number = 50): Promise<Transaction[]> {
    const items: Transaction[] = await this.listAll();
    return items.slice(0, limit);
  }

  async getById(id: number): Promise<Transaction | null> {
    const items: Transaction[] = await this.listAll();
    const target: Transaction | undefined = items.find((item: Transaction) => item.id === id);
    return target ?? null;
  }

  async create(payload: Omit<Transaction, 'id' | 'createdAt'>): Promise<number> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const rowId: number = await store.insert('transactions', {
      type: payload.type,
      amount: payload.amount,
      categoryId: payload.categoryId,
      note: payload.note,
      date: payload.date,
      createdAt: Date.now()
    });
    return rowId;
  }

  async update(transaction: Transaction): Promise<void> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('transactions');
    predicates.equalTo('id', transaction.id);
    await store.update({
      type: transaction.type,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt
    }, predicates);
  }

  async delete(id: number): Promise<void> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('transactions');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async listByMonth(month: string): Promise<Transaction[]> {
    const items: Transaction[] = await this.listAll();
    return items.filter((item: Transaction) => DateUtils.isSameMonth(item.date, month));
  }

  async getMonthSummary(month: string): Promise<MonthlySummary> {
    const items: Transaction[] = await this.listByMonth(month);
    let income: number = 0;
    let expense: number = 0;
    items.forEach((item: Transaction) => {
      if (item.type === 'income') {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    });
    return {
      month,
      income,
      expense,
      balance: income - expense,
      transactionCount: items.length
    };
  }

  async getDailyTrend(days: number = 30): Promise<DailyTrendPoint[]> {
    const dateKeys: string[] = DateUtils.recentDates(days);
    const map: Record<string, number> = {};
    dateKeys.forEach((date: string) => {
      map[date] = 0;
    });
    const items: Transaction[] = await this.listAll();
    items.forEach((item: Transaction) => {
      if (map[item.date] === undefined) {
        return;
      }
      map[item.date] += item.type === 'income' ? item.amount : -item.amount;
    });
    return dateKeys.map((date: string) => ({
      date,
      amount: map[date]
    }));
  }

  async getExpensePie(month: string, categoryMeta: Record<number, { name: string; color: string }>): Promise<PieChartItem[]> {
    const totals: Record<number, number> = {};
    const items: Transaction[] = await this.listByMonth(month);
    items.forEach((item: Transaction) => {
      if (item.type !== 'expense') {
        return;
      }
      totals[item.categoryId] = (totals[item.categoryId] ?? 0) + item.amount;
    });
    return Object.keys(totals).map((key: string) => {
      const categoryId: number = Number(key);
      const category = categoryMeta[categoryId] ?? { name: '未分类', color: '#BDBDBD' };
      return {
        categoryId,
        label: category.name,
        color: category.color,
        amount: totals[categoryId]
      };
    }).sort((left: PieChartItem, right: PieChartItem) => right.amount - left.amount);
  }

  async getTodayExpense(): Promise<number> {
    const today: string = DateUtils.currentDateString();
    const items: Transaction[] = await this.listAll();
    return items.filter((item: Transaction) => item.date === today && item.type === 'expense')
      .reduce((total: number, item: Transaction) => total + item.amount, 0);
  }

  async exportCsv(month?: string): Promise<string> {
    const items: Transaction[] = month ? await this.listByMonth(month) : await this.listAll();
    const rows: string[] = ['id,type,amount,categoryId,note,date,createdAt'];
    items.forEach((item: Transaction) => {
      const escapedNote: string = item.note.replace(/"/g, '""');
      rows.push(`${item.id},${item.type},${item.amount.toFixed(2)},${item.categoryId},"${escapedNote}",${item.date},${item.createdAt}`);
    });
    return rows.join('\n');
  }
}
