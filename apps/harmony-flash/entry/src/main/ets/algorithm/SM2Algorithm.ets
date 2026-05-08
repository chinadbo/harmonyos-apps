import { Card } from '../model/Card';

/**
 * SM-2 间隔重复算法
 * quality 评分：
 *   0 = 完全不记得（重置）
 *   3 = 困难但记得（一般）
 *   5 = 轻松记得（熟悉）
 */
export function sm2(card: Card, quality: number): Card {
  const updated: Card = { ...card };

  if (quality < 3) {
    // 评分低于 3 → 重置
    updated.repetitions = 0;
    updated.interval = 1;
  } else {
    if (updated.repetitions === 0) {
      updated.interval = 1;
    } else if (updated.repetitions === 1) {
      updated.interval = 6;
    } else {
      updated.interval = Math.round(updated.interval * updated.easeFactor);
    }
    updated.repetitions += 1;
  }

  // 更新难度因子 EF
  const q = quality;
  updated.easeFactor = updated.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  if (updated.easeFactor < 1.3) {
    updated.easeFactor = 1.3;
  }

  // 下次复习时间戳
  updated.nextReviewDate = Date.now() + updated.interval * 24 * 60 * 60 * 1000;

  // 掌握等级（0-5）
  updated.masteryLevel = Math.min(5, updated.repetitions);

  return updated;
}

/**
 * 今日待复习判断：nextReviewDate <= 今天结束
 */
export function isDueToday(card: Card): boolean {
  const todayEnd = new Date();
  todayEnd.setHours(23, 59, 59, 999);
  return card.nextReviewDate <= todayEnd.getTime();
}
