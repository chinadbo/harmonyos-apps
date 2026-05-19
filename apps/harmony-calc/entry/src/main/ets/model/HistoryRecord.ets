export type CalculatorMode = 'standard' | 'scientific';

export class HistoryRecord {
  id: number = 0;
  expression: string = '';
  result: string = '';
  mode: string = 'standard';
  createdAt: number = 0;

  constructor(id: number = 0, expression: string = '', result: string = '', mode: string = 'standard', createdAt: number = 0) {
    this.id = id;
    this.expression = expression;
    this.result = result;
    this.mode = mode;
    this.createdAt = createdAt;
  }
}
