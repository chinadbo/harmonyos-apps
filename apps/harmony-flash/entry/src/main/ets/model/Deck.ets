export interface Deck {
  id: number;
  name: string;
  description: string;
  cardCount: number;
  masteredCount: number;
  createdAt: number;
  isBuiltIn: number; // 0=自定义 1=内置
}

export function createDeck(name: string, description: string = '', isBuiltIn: number = 0): Deck {
  return {
    id: 0,
    name,
    description,
    cardCount: 0,
    masteredCount: 0,
    createdAt: Date.now(),
    isBuiltIn
  };
}
