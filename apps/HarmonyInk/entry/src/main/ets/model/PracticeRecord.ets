/** 一条练习记录（对应 RDB practice 表） */
export interface PracticeRecord {
  id?: number;
  char: string;
  score: number;
  strokeCount: number;
  durationMs: number;
  createdAt: number;
}

/** 单字聚合统计 */
export interface CharStat {
  char: string;
  bestScore: number;
  attempts: number;
  lastTime: number;
  avgScore: number;
}

/** 按天聚合统计（热力图数据源） */
export interface DayStat {
  dayKey: string;
  count: number;
  avgScore: number;
}

/** 全局概览 */
export interface OverallStats {
  totalAttempts: number;
  totalChars: number;
  avgScore: number;
  todayCount: number;
  masteredCount: number;
}

/** 掌握度计算：最佳分占 80%，练习频次占 20% */
export class MasteryUtil {
  static mastery(bestScore: number, attempts: number): number {
    if (attempts <= 0) {
      return 0;
    }
    const bestPart: number = bestScore * 0.8;
    const freqPart: number = Math.min(attempts, 6) / 6 * 20;
    return Math.min(100, Math.round(bestPart + freqPart));
  }

  static isMastered(bestScore: number, attempts: number): boolean {
    return bestScore >= 85 && attempts >= 3;
  }

  static stars(bestScore: number): number {
    if (bestScore >= 95) {
      return 5;
    }
    if (bestScore >= 85) {
      return 4;
    }
    if (bestScore >= 70) {
      return 3;
    }
    if (bestScore >= 50) {
      return 2;
    }
    return bestScore > 0 ? 1 : 0;
  }
}
