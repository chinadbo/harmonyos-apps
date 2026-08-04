// 标签数据模型，定义标签结构和默认值
export interface TagModel {
  id: number;
  name: string;
  color: string;
  sortOrder: number;
  isPreset?: boolean;
}

export function createEmptyTagModel(): TagModel {
  return {
    id: 0,
    name: '',
    color: '#4A90D9',
    sortOrder: 0,
    isPreset: false
  };
}
