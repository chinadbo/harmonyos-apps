/**
 * 刷题记录实体
 * status: 0 未做 / 1 已做 / 2 掌握
 */
export const STATUS_TODO: number = 0;
export const STATUS_DONE: number = 1;
export const STATUS_MASTERED: number = 2;

export class LearningRecord {
  problemId: number;
  status: number;
  wrongCount: number;
  updatedAt: number;

  constructor(problemId: number, status: number, wrongCount: number, updatedAt: number) {
    this.problemId = problemId;
    this.status = status;
    this.wrongCount = wrongCount;
    this.updatedAt = updatedAt;
  }
}

/** 状态中文标签 */
export function statusLabel(status: number): string {
  if (status === STATUS_DONE) {
    return '已做';
  }
  if (status === STATUS_MASTERED) {
    return '已掌握';
  }
  return '未做';
}
