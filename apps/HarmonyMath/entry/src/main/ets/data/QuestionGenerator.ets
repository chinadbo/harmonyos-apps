import { Question } from '../model/Models';

export class QuestionGenerator {
  static generate(mode: string, difficulty: number, count: number): Question[] {
    const result: Question[] = [];
    const seen: Set<string> = new Set<string>();
    let attempts: number = 0;
    const maxAttempts: number = count * 80;
    while (result.length < count && attempts < maxAttempts) {
      attempts += 1;
      let q: Question | null = null;
      if (difficulty === 3) {
        q = QuestionGenerator.buildTwoStep(mode);
      } else {
        q = QuestionGenerator.buildBasic(mode, difficulty);
      }
      if (q === null) {
        continue;
      }
      if (seen.has(q.stem)) {
        continue;
      }
      seen.add(q.stem);
      result.push(q);
    }
    return result;
  }

  private static pickOp(mode: string): string {
    if (mode === 'add') {
      return 'add';
    }
    if (mode === 'sub') {
      return 'sub';
    }
    if (mode === 'mul') {
      return 'mul';
    }
    if (mode === 'div') {
      return 'div';
    }
    if (mode === 'addsub') {
      return QuestionGenerator.randInt(0, 1) === 0 ? 'add' : 'sub';
    }
    if (mode === 'muldiv') {
      return QuestionGenerator.randInt(0, 1) === 0 ? 'mul' : 'div';
    }
    const r: number = QuestionGenerator.randInt(0, 3);
    if (r === 0) {
      return 'add';
    }
    if (r === 1) {
      return 'sub';
    }
    if (r === 2) {
      return 'mul';
    }
    return 'div';
  }

  private static buildBasic(mode: string, difficulty: number): Question | null {
    const op: string = QuestionGenerator.pickOp(mode);
    if (op === 'add') {
      return QuestionGenerator.addQuestion(difficulty);
    }
    if (op === 'sub') {
      return QuestionGenerator.subQuestion(difficulty);
    }
    if (op === 'mul') {
      return QuestionGenerator.mulQuestion(difficulty);
    }
    if (op === 'div') {
      return QuestionGenerator.divQuestion(difficulty);
    }
    return null;
  }

  private static buildTwoStep(mode: string): Question | null {
    const op: string = QuestionGenerator.pickOp(mode);
    if (op === 'div') {
      return QuestionGenerator.divQuestion(3);
    }
    if (op === 'mul' && QuestionGenerator.randInt(0, 1) === 0) {
      return QuestionGenerator.mulQuestion(3);
    }
    const pattern: number = QuestionGenerator.randInt(1, 4);
    if (pattern === 1) {
      const a: number = QuestionGenerator.randInt(1, 9);
      const b: number = QuestionGenerator.randInt(1, 9);
      const c: number = QuestionGenerator.randInt(2, 9);
      const q: Question = { stem: `(${a} + ${b}) × ${c} = ?`, answer: (a + b) * c };
      return q;
    }
    if (pattern === 2) {
      const a: number = QuestionGenerator.randInt(2, 9);
      const b: number = QuestionGenerator.randInt(2, 9);
      const product: number = a * b;
      const c: number = QuestionGenerator.randInt(1, Math.min(20, product));
      const q: Question = { stem: `${a} × ${b} − ${c} = ?`, answer: product - c };
      return q;
    }
    if (pattern === 3) {
      const a: number = QuestionGenerator.randInt(3, 9);
      const b: number = QuestionGenerator.randInt(1, a - 1);
      const c: number = QuestionGenerator.randInt(2, 9);
      const q: Question = { stem: `(${a} − ${b}) × ${c} = ?`, answer: (a - b) * c };
      return q;
    }
    const a: number = QuestionGenerator.randInt(2, 9);
    const b: number = QuestionGenerator.randInt(1, 8);
    const c: number = QuestionGenerator.randInt(1, 9 - b);
    const q: Question = { stem: `${a} × (${b} + ${c}) = ?`, answer: a * (b + c) };
    return q;
  }

  private static addQuestion(difficulty: number): Question {
    if (difficulty === 1) {
      const a: number = QuestionGenerator.randInt(1, 9);
      const b: number = QuestionGenerator.randInt(1, 9);
      const q: Question = { stem: `${a} + ${b} = ?`, answer: a + b };
      return q;
    }
    const a: number = QuestionGenerator.randInt(10, 99);
    const b: number = QuestionGenerator.randInt(10, 99);
    const q: Question = { stem: `${a} + ${b} = ?`, answer: a + b };
    return q;
  }

  private static subQuestion(difficulty: number): Question {
    if (difficulty === 1) {
      const a: number = QuestionGenerator.randInt(2, 10);
      const b: number = QuestionGenerator.randInt(1, a);
      const q: Question = { stem: `${a} − ${b} = ?`, answer: a - b };
      return q;
    }
    const a: number = QuestionGenerator.randInt(20, 99);
    const b: number = QuestionGenerator.randInt(10, a);
    const q: Question = { stem: `${a} − ${b} = ?`, answer: a - b };
    return q;
  }

  private static mulQuestion(difficulty: number): Question {
    if (difficulty === 1) {
      const a: number = QuestionGenerator.randInt(2, 9);
      const b: number = QuestionGenerator.randInt(1, 9);
      const q: Question = { stem: `${a} × ${b} = ?`, answer: a * b };
      return q;
    }
    const a: number = QuestionGenerator.randInt(2, 12);
    const b: number = QuestionGenerator.randInt(2, 9);
    const q: Question = { stem: `${a} × ${b} = ?`, answer: a * b };
    return q;
  }

  private static divQuestion(difficulty: number): Question {
    if (difficulty === 1) {
      const b: number = QuestionGenerator.randInt(2, 9);
      const quotient: number = QuestionGenerator.randInt(1, 9);
      const q: Question = { stem: `${b * quotient} ÷ ${b} = ?`, answer: quotient };
      return q;
    }
    if (difficulty === 2) {
      const b: number = QuestionGenerator.randInt(2, 9);
      const quotient: number = QuestionGenerator.randInt(2, 12);
      const q: Question = { stem: `${b * quotient} ÷ ${b} = ?`, answer: quotient };
      return q;
    }
    const b: number = QuestionGenerator.randInt(2, 9);
    const quotient: number = QuestionGenerator.randInt(2, 9);
    const q: Question = { stem: `${b * quotient} ÷ ${b} = ?`, answer: quotient };
    return q;
  }

  private static randInt(min: number, max: number): number {
    return min + Math.floor(Math.random() * (max - min + 1));
  }
}
