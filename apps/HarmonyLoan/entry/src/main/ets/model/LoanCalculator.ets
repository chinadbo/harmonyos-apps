import { CalcResult, LoanInput, PaymentRow, PrepayResult, PrepayStrategy } from './LoanTypes';

export interface YearPoint {
  year: number;
  principalFen: number;
  interestFen: number;
}

export class LoanCalculator {
  static emptyResult(): CalcResult {
    return {
      monthlyFen: 0,
      totalInterestFen: 0,
      totalPayFen: 0,
      totalPrincipalFen: 0,
      rows: []
    };
  }

  /** 月利率：bp 为万分之一（1bp = 0.01%），r = bp / 10000 / 12 */
  static monthlyRate(rateBp: number): number {
    return rateBp / 120000;
  }

  static equalPaymentMonthly(principalFen: number, rateBp: number, months: number): number {
    if (principalFen <= 0 || months <= 0) {
      return 0;
    }
    const r = LoanCalculator.monthlyRate(rateBp);
    if (r <= 0) {
      return Math.ceil(principalFen / months);
    }
    const f = Math.pow(1 + r, months);
    return Math.round(principalFen * r * f / (f - 1));
  }

  static equalPaymentSchedule(principalFen: number, rateBp: number, months: number,
    fixedMonthlyFen: number): PaymentRow[] {
    const rows: PaymentRow[] = [];
    if (principalFen <= 0 || months <= 0) {
      return rows;
    }
    const r = LoanCalculator.monthlyRate(rateBp);
    let monthly = fixedMonthlyFen;
    if (monthly <= 0) {
      monthly = LoanCalculator.equalPaymentMonthly(principalFen, rateBp, months);
    }
    let remain = principalFen;
    for (let i = 1; i <= months; i++) {
      const interest = Math.round(remain * r);
      let principle = monthly - interest;
      let pay = monthly;
      if (i === months || principle >= remain) {
        principle = remain;
        pay = principle + interest;
      }
      if (principle < 0) {
        principle = 0;
        pay = interest;
      }
      remain -= principle;
      rows.push({
        idx: i,
        monthPayFen: pay,
        principalFen: principle,
        interestFen: interest,
        remainFen: remain
      });
      if (remain <= 0) {
        break;
      }
    }
    return rows;
  }

  static equalPrincipalSchedule(principalFen: number, rateBp: number, months: number): PaymentRow[] {
    const rows: PaymentRow[] = [];
    if (principalFen <= 0 || months <= 0) {
      return rows;
    }
    const r = LoanCalculator.monthlyRate(rateBp);
    const base = Math.floor(principalFen / months);
    const rest = principalFen - base * months;
    let remain = principalFen;
    for (let i = 1; i <= months; i++) {
      let principle = base;
      if (i === 1) {
        principle = base + rest;
      }
      if (i === months) {
        principle = remain;
      }
      const interest = Math.round(remain * r);
      remain -= principle;
      rows.push({
        idx: i,
        monthPayFen: principle + interest,
        principalFen: principle,
        interestFen: interest,
        remainFen: remain
      });
      if (remain <= 0) {
        break;
      }
    }
    return rows;
  }

  static scheduleOf(principalFen: number, rateBp: number, months: number, mode: string,
    fixedMonthlyFen: number): PaymentRow[] {
    if (mode === 'equal_principal') {
      return LoanCalculator.equalPrincipalSchedule(principalFen, rateBp, months);
    }
    return LoanCalculator.equalPaymentSchedule(principalFen, rateBp, months, fixedMonthlyFen);
  }

  static summarize(rows: PaymentRow[]): CalcResult {
    let interest = 0;
    let pay = 0;
    let principal = 0;
    for (let i = 0; i < rows.length; i++) {
      interest += rows[i].interestFen;
      pay += rows[i].monthPayFen;
      principal += rows[i].principalFen;
    }
    const monthly = rows.length > 0 ? rows[0].monthPayFen : 0;
    const result: CalcResult = {
      monthlyFen: monthly,
      totalInterestFen: interest,
      totalPayFen: pay,
      totalPrincipalFen: principal,
      rows: rows
    };
    return result;
  }

  static calcSingle(principalFen: number, rateBp: number, months: number, mode: string): CalcResult {
    if (principalFen <= 0 || months <= 0) {
      return LoanCalculator.emptyResult();
    }
    if (mode === 'equal_principal') {
      return LoanCalculator.summarize(LoanCalculator.equalPrincipalSchedule(principalFen, rateBp, months));
    }
    const monthly = LoanCalculator.equalPaymentMonthly(principalFen, rateBp, months);
    return LoanCalculator.summarize(LoanCalculator.equalPaymentSchedule(principalFen, rateBp, months, monthly));
  }

  static calc(input: LoanInput): CalcResult {
    if (input.months <= 0) {
      return LoanCalculator.emptyResult();
    }
    if (input.type === 'combined') {
      const commercial = LoanCalculator.calcSingle(input.commercialFen, input.commercialRateBp,
        input.months, input.mode);
      const provident = LoanCalculator.calcSingle(input.providentFen, input.providentRateBp,
        input.months, input.mode);
      return LoanCalculator.merge(commercial, provident);
    }
    return LoanCalculator.calcSingle(input.amountFen, input.rateBp, input.months, input.mode);
  }

  private static merge(a: CalcResult, b: CalcResult): CalcResult {
    if (a.rows.length === 0) {
      return b;
    }
    if (b.rows.length === 0) {
      return a;
    }
    const rows: PaymentRow[] = [];
    const count = Math.max(a.rows.length, b.rows.length);
    for (let i = 0; i < count; i++) {
      let pay = 0;
      let principle = 0;
      let interest = 0;
      let remain = 0;
      if (i < a.rows.length) {
        pay += a.rows[i].monthPayFen;
        principle += a.rows[i].principalFen;
        interest += a.rows[i].interestFen;
        remain += a.rows[i].remainFen;
      }
      if (i < b.rows.length) {
        pay += b.rows[i].monthPayFen;
        principle += b.rows[i].principalFen;
        interest += b.rows[i].interestFen;
        remain += b.rows[i].remainFen;
      }
      rows.push({
        idx: i + 1,
        monthPayFen: pay,
        principalFen: principle,
        interestFen: interest,
        remainFen: remain
      });
    }
    const result: CalcResult = {
      monthlyFen: a.monthlyFen + b.monthlyFen,
      totalInterestFen: a.totalInterestFen + b.totalInterestFen,
      totalPayFen: a.totalPayFen + b.totalPayFen,
      totalPrincipalFen: a.totalPrincipalFen + b.totalPrincipalFen,
      rows: rows
    };
    return result;
  }

  /** 组合贷/单贷统一折算有效年利率（bp），用于提前还款重算 */
  private static effectiveRateBp(input: LoanInput, result: CalcResult): number {
    if (input.type !== 'combined') {
      return input.rateBp;
    }
    if (result.rows.length === 0) {
      return input.rateBp;
    }
    const first = result.rows[0];
    const start = first.principalFen + first.remainFen;
    if (start <= 0) {
      return input.rateBp;
    }
    return Math.round(first.interestFen / start * 120000);
  }

  static periodsForPayment(principalFen: number, rateBp: number, monthlyFen: number): number {
    if (principalFen <= 0) {
      return 0;
    }
    if (monthlyFen <= 0) {
      return 1;
    }
    const r = LoanCalculator.monthlyRate(rateBp);
    if (r <= 0) {
      return Math.max(1, Math.ceil(principalFen / monthlyFen));
    }
    const base = monthlyFen - principalFen * r;
    if (base <= 0) {
      return 1;
    }
    const n = Math.log(monthlyFen / base) / Math.log(1 + r);
    return Math.max(1, Math.ceil(n));
  }

  static prepay(input: LoanInput, prepayFen: number, afterMonths: number,
    strategy: PrepayStrategy): PrepayResult {
    const original = LoanCalculator.calc(input);
    const invalid: PrepayResult = {
      valid: false,
      prepayFen: prepayFen,
      afterMonths: afterMonths,
      strategy: strategy,
      oldMonthlyFen: original.monthlyFen,
      newMonthlyFen: 0,
      oldMonths: original.rows.length,
      newMonths: 0,
      remainBeforeFen: 0,
      remainAfterFen: 0,
      interestPaidBeforeFen: 0,
      newTotalInterestFen: 0,
      savedInterestFen: 0,
      rows: []
    };
    if (original.rows.length === 0 || prepayFen <= 0) {
      return invalid;
    }
    const m = Math.floor(afterMonths);
    if (m < 1 || m >= original.rows.length) {
      return invalid;
    }
    const remainBefore = original.rows[m - 1].remainFen;
    if (remainBefore <= 0) {
      return invalid;
    }
    let pay = prepayFen;
    if (pay > remainBefore) {
      pay = remainBefore;
    }
    const remainAfter = remainBefore - pay;
    let interestPaidBefore = 0;
    for (let i = 0; i < m; i++) {
      interestPaidBefore += original.rows[i].interestFen;
    }
    const remainPeriods = original.rows.length - m;
    const rateBp = LoanCalculator.effectiveRateBp(input, original);
    const rows: PaymentRow[] = [];
    if (remainAfter > 0 && remainPeriods > 0) {
      if (input.mode === 'equal_payment') {
        if (strategy === 'shorten') {
          const newPeriods = LoanCalculator.periodsForPayment(remainAfter, rateBp, original.monthlyFen);
          const limited = Math.min(newPeriods, remainPeriods);
          const schedule = LoanCalculator.equalPaymentSchedule(remainAfter, rateBp, limited,
            original.monthlyFen);
          for (let i = 0; i < schedule.length; i++) {
            rows.push(schedule[i]);
          }
        } else {
          const newMonthly = LoanCalculator.equalPaymentMonthly(remainAfter, rateBp, remainPeriods);
          const schedule = LoanCalculator.equalPaymentSchedule(remainAfter, rateBp, remainPeriods,
            newMonthly);
          for (let i = 0; i < schedule.length; i++) {
            rows.push(schedule[i]);
          }
        }
      } else {
        let basePrincipal = 0;
        if (m < original.rows.length) {
          basePrincipal = original.rows[m].principalFen;
        } else {
          basePrincipal = original.rows[m - 1].principalFen;
        }
        let newPeriods = remainPeriods;
        if (strategy === 'shorten' && basePrincipal > 0) {
          newPeriods = Math.ceil(remainAfter / basePrincipal);
          if (newPeriods > remainPeriods) {
            newPeriods = remainPeriods;
          }
          if (newPeriods < 1) {
            newPeriods = 1;
          }
        }
        const schedule = LoanCalculator.equalPrincipalSchedule(remainAfter, rateBp, newPeriods);
        for (let i = 0; i < schedule.length; i++) {
          rows.push(schedule[i]);
        }
      }
    }
    let newTotalInterest = 0;
    for (let i = 0; i < rows.length; i++) {
      newTotalInterest += rows[i].interestFen;
    }
    let saved = original.totalInterestFen - interestPaidBefore - newTotalInterest;
    if (saved < 0) {
      saved = 0;
    }
    const newMonthly = rows.length > 0 ? rows[0].monthPayFen : 0;
    const result: PrepayResult = {
      valid: true,
      prepayFen: pay,
      afterMonths: m,
      strategy: strategy,
      oldMonthlyFen: original.monthlyFen,
      newMonthlyFen: newMonthly,
      oldMonths: original.rows.length,
      newMonths: rows.length,
      remainBeforeFen: remainBefore,
      remainAfterFen: remainAfter,
      interestPaidBeforeFen: interestPaidBefore,
      newTotalInterestFen: newTotalInterest,
      savedInterestFen: saved,
      rows: rows
    };
    return result;
  }

  static yearly(rows: PaymentRow[]): YearPoint[] {
    const points: YearPoint[] = [];
    let year = 1;
    let principle = 0;
    let interest = 0;
    for (let i = 0; i < rows.length; i++) {
      principle += rows[i].principalFen;
      interest += rows[i].interestFen;
      const isYearEnd = (i + 1) % 12 === 0;
      const isLast = i === rows.length - 1;
      if (isYearEnd || isLast) {
        points.push({
          year: year,
          principalFen: principle,
          interestFen: interest
        });
        year++;
        principle = 0;
        interest = 0;
      }
    }
    return points;
  }

  static fenToYuan(fen: number): string {
    const negative = fen < 0;
    const abs = negative ? -fen : fen;
    const yuan = Math.floor(abs / 100);
    const cents = abs % 100;
    let yuanText = yuan.toString();
    let grouped = '';
    let count = 0;
    for (let i = yuanText.length - 1; i >= 0; i--) {
      grouped = yuanText.charAt(i) + grouped;
      count++;
      if (count % 3 === 0 && i > 0) {
        grouped = ',' + grouped;
      }
    }
    const centText = cents < 10 ? '0' + cents.toString() : cents.toString();
    return (negative ? '-' : '') + grouped + '.' + centText;
  }

  static fenToYuanNoDecimal(fen: number): string {
    const negative = fen < 0;
    const abs = negative ? -fen : fen;
    const yuan = Math.round(abs / 100);
    let text = yuan.toString();
    let grouped = '';
    let count = 0;
    for (let i = text.length - 1; i >= 0; i--) {
      grouped = text.charAt(i) + grouped;
      count++;
      if (count % 3 === 0 && i > 0) {
        grouped = ',' + grouped;
      }
    }
    return (negative ? '-' : '') + grouped;
  }

  static fenToWan(fen: number): string {
    const wan = fen / 1000000;
    let text = wan.toFixed(2);
    while (text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  static parseWanToFen(text: string): number {
    if (text.length === 0) {
      return 0;
    }
    const value = parseFloat(text);
    if (value !== value || value < 0) {
      return 0;
    }
    return Math.round(value * 1000000);
  }

  static parseRateToBp(text: string): number {
    if (text.length === 0) {
      return 0;
    }
    const value = parseFloat(text);
    if (value !== value || value < 0) {
      return 0;
    }
    return Math.round(value * 100);
  }

  static bpToRateText(bp: number): string {
    let text = (bp / 100).toFixed(2);
    while (text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  static bpToPercent(bp: number): string {
    return (bp / 100).toFixed(2) + '%';
  }
}
