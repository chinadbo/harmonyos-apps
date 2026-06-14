export const GROUP_SCENES: string[] = ['travel', 'dinner', 'rent', 'other'];
export const GROUP_SCENE_LABELS: { [key: string]: string } = {
  travel: '旅行',
  dinner: '聚餐',
  rent: '合租',
  other: '其他'
};

export interface Group {
  id: number;
  name: string;
  scene: string;
  createdAt: number;
  isSettled: number;
}

export interface GroupSummary extends Group {
  memberCount: number;
  billCount: number;
  totalAmount: number;
}

export const EMPTY_GROUP: Group = {
  id: 0,
  name: '',
  scene: 'other',
  createdAt: 0,
  isSettled: 0
};
