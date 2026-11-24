/**
 * 题目实体
 * difficulty: 1 简单 / 2 中等 / 3 困难
 */
export class Problem {
  id: number;
  title: string;
  category: string;
  difficulty: number;
  description: string;
  analysis: string;
  codeArkts: string;
  codePython: string;
  tags: string;

  constructor(id: number, title: string, category: string, difficulty: number,
    description: string, analysis: string, codeArkts: string, codePython: string, tags: string) {
    this.id = id;
    this.title = title;
    this.category = category;
    this.difficulty = difficulty;
    this.description = description;
    this.analysis = analysis;
    this.codeArkts = codeArkts;
    this.codePython = codePython;
    this.tags = tags;
  }
}

export const DIFFICULTY_EASY: number = 1;
export const DIFFICULTY_MEDIUM: number = 2;
export const DIFFICULTY_HARD: number = 3;

/** 难度中文标签 */
export function difficultyLabel(difficulty: number): string {
  if (difficulty === DIFFICULTY_EASY) {
    return '简单';
  }
  if (difficulty === DIFFICULTY_MEDIUM) {
    return '中等';
  }
  return '困难';
}

/** 难度对应颜色 */
export function difficultyColor(difficulty: number): string {
  if (difficulty === DIFFICULTY_EASY) {
    return '#27C46B';
  }
  if (difficulty === DIFFICULTY_MEDIUM) {
    return '#FF9F1C';
  }
  return '#FF4D4F';
}
