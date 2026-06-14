export class FormatUtils {
  static fenToYuan(amount: number): string {
    return (amount / 100).toFixed(2);
  }

  static formatCurrency(amount: number): string {
    return `¥${FormatUtils.fenToYuan(amount)}`;
  }

  static parseAmountInput(value: string): number {
    const parsed = Number.parseFloat(value);
    if (Number.isNaN(parsed) || parsed < 0) {
      return 0;
    }
    return Math.round(parsed * 100);
  }

  static formatDateTime(timestamp: number): string {
    if (!timestamp) {
      return '--';
    }
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${year}-${month}-${day} ${hour}:${minute}`;
  }
}
