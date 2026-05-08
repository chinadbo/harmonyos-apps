export interface StudyRecord {
  id: number;
  cardId: number;
  deckId: number;
  quality: number;     // 0=不熟, 3=一般, 5=熟悉
  reviewDate: number;  // 复习时间戳（ms）
}

export function createStudyRecord(
  cardId: number,
  deckId: number,
  quality: number
): StudyRecord {
  return {
    id: 0,
    cardId,
    deckId,
    quality,
    reviewDate: Date.now()
  };
}
