export type TransactionType = 'income' | 'expense';
export type CategoryType = 'income' | 'expense' | 'both';

export interface Transaction {
  id: number;
  type: TransactionType;
  amount: number;
  categoryId: number;
  note: string;
  date: string;
  createdAt: number;
}

export interface Category {
  id: number;
  name: string;
  icon: string;
  color: string;
  type: CategoryType;
  isSystem: boolean;
  sortOrder: number;
}

export interface Budget {
  id: number;
  categoryId: number;
  month: string;
  amount: number;
}

export interface MonthlySummary {
  month: string;
  income: number;
  expense: number;
  balance: number;
  transactionCount: number;
}

export interface DailyTrendPoint {
  date: string;
  amount: number;
}

export interface PieChartItem {
  categoryId: number;
  label: string;
  color: string;
  amount: number;
}

export interface BudgetStatus {
  budget: Budget;
  category: Category;
  spent: number;
  remaining: number;
  progress: number;
  overBudget: boolean;
}

export interface WidgetSummary {
  monthlyBalance: number;
  todayExpense: number;
  currency: string;
}

export class TransactionDataSource implements IDataSource {
  private list: Transaction[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): Transaction {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index: number = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  setData(data: Transaction[]): void {
    this.list = data.slice();
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  getAll(): Transaction[] {
    return this.list.slice();
  }
}
