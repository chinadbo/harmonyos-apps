export type LoanType = 'commercial' | 'provident' | 'combined';
export type RepayMode = 'equal_payment' | 'equal_principal';
export type PrepayStrategy = 'shorten' | 'reduce';

export interface LoanInput {
  amountFen: number;
  months: number;
  rateBp: number;
  type: LoanType;
  mode: RepayMode;
  commercialFen: number;
  commercialRateBp: number;
  providentFen: number;
  providentRateBp: number;
}

export interface PaymentRow {
  idx: number;
  monthPayFen: number;
  principalFen: number;
  interestFen: number;
  remainFen: number;
}

export interface CalcResult {
  monthlyFen: number;
  totalInterestFen: number;
  totalPayFen: number;
  totalPrincipalFen: number;
  rows: PaymentRow[];
}

export interface LoanPlan {
  id?: number;
  name: string;
  input: LoanInput;
  monthlyFen: number;
  totalInterestFen: number;
  createdAt: number;
}

export interface PrepayResult {
  valid: boolean;
  prepayFen: number;
  afterMonths: number;
  strategy: PrepayStrategy;
  oldMonthlyFen: number;
  newMonthlyFen: number;
  oldMonths: number;
  newMonths: number;
  remainBeforeFen: number;
  remainAfterFen: number;
  interestPaidBeforeFen: number;
  newTotalInterestFen: number;
  savedInterestFen: number;
  rows: PaymentRow[];
}

export function defaultLoanInput(): LoanInput {
  return {
    amountFen: 100000000,
    months: 360,
    rateBp: 350,
    type: 'commercial',
    mode: 'equal_payment',
    commercialFen: 100000000,
    commercialRateBp: 350,
    providentFen: 0,
    providentRateBp: 285
  };
}

export function loanTypeLabel(type: LoanType): string {
  if (type === 'provident') {
    return '公积金贷款';
  }
  if (type === 'combined') {
    return '组合贷款';
  }
  return '商业贷款';
}

export function repayModeLabel(mode: RepayMode): string {
  return mode === 'equal_payment' ? '等额本息' : '等额本金';
}
