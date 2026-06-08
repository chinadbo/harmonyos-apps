export interface CategoryItem {
  id?: number;
  name: string;
  color: string;
  sortOrder: number;
  createdAt: number;
}

export const DEFAULT_CATEGORIES: CategoryItem[] = [
  { name: '工作', color: '#FF6B6B', sortOrder: 0, createdAt: 0 },
  { name: '学习', color: '#4ECDC4', sortOrder: 1, createdAt: 0 },
  { name: '生活', color: '#45B7D1', sortOrder: 2, createdAt: 0 },
  { name: '购物', color: '#96CEB4', sortOrder: 3, createdAt: 0 },
  { name: '其他', color: '#FFEAA7', sortOrder: 4, createdAt: 0 }
];
