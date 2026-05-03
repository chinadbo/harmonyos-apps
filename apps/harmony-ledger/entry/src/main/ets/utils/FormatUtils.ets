export class FormatUtils {
  static formatAmount(amount: number, currency: string = '¥'): string {
    const sign: string = amount < 0 ? '-' : '';
    return `${sign}${currency}${Math.abs(amount).toFixed(2)}`;
  }

  static formatSignedAmount(amount: number, type: 'income' | 'expense', currency: string = '¥'): string {
    const prefix: string = type === 'income' ? '+' : '-';
    return `${prefix}${currency}${Math.abs(amount).toFixed(2)}`;
  }

  static formatPercent(value: number): string {
    return `${(value * 100).toFixed(0)}%`;
  }
}
