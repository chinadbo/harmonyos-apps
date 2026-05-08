export interface Card {
  id: number;
  deckId: number;
  front: string;         // 单词/问题（正面）
  back: string;          // 释义/答案（背面）
  phonetic: string;      // 音标（可选）
  example: string;       // 例句（可选）
  // SM-2 算法字段
  easeFactor: number;    // 难度因子，初始 2.5，最小 1.3
  interval: number;      // 复习间隔（天），初始 1
  repetitions: number;   // 连续正确复习次数
  nextReviewDate: number; // 下次复习时间戳（ms）
  masteryLevel: number;  // 掌握等级 0-5
}

export function createCard(
  deckId: number,
  front: string,
  back: string,
  phonetic: string = '',
  example: string = ''
): Card {
  return {
    id: 0,
    deckId,
    front,
    back,
    phonetic,
    example,
    easeFactor: 2.5,
    interval: 1,
    repetitions: 0,
    nextReviewDate: Date.now(),
    masteryLevel: 0
  };
}
