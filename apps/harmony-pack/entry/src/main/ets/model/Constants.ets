export enum TripType {
  BUSINESS = 'business',
  LEISURE = 'leisure',
  ABROAD = 'abroad',
  BACKPACK = 'backpack'
}

export enum ItemCategory {
  CLOTHES = 'clothes',
  DOCUMENTS = 'documents',
  ELECTRONICS = 'electronics',
  TOILETRIES = 'toiletries',
  MEDICINE = 'medicine',
  OTHER = 'other'
}

export enum TripStatus {
  UPCOMING = 'upcoming',
  ACTIVE = 'active',
  COMPLETED = 'completed'
}

export const TRIP_TYPE_OPTIONS: Array<{ value: string; label: string }> = [
  { value: TripType.BUSINESS, label: '商务出差' },
  { value: TripType.LEISURE, label: '休闲度假' },
  { value: TripType.ABROAD, label: '海外游' },
  { value: TripType.BACKPACK, label: '背包客' }
]

export const CATEGORY_OPTIONS: Array<{ value: string; label: string }> = [
  { value: ItemCategory.CLOTHES, label: '衣物' },
  { value: ItemCategory.DOCUMENTS, label: '证件' },
  { value: ItemCategory.ELECTRONICS, label: '电子设备' },
  { value: ItemCategory.TOILETRIES, label: '洗漱用品' },
  { value: ItemCategory.MEDICINE, label: '药物' },
  { value: ItemCategory.OTHER, label: '其他' }
]

export const STATUS_OPTIONS: Array<{ value: string; label: string }> = [
  { value: TripStatus.UPCOMING, label: '待出发' },
  { value: TripStatus.ACTIVE, label: '进行中' },
  { value: TripStatus.COMPLETED, label: '已完成' }
]

export const CATEGORY_COLORS: Record<string, string> = {
  [ItemCategory.CLOTHES]: '#FF6B6B',
  [ItemCategory.DOCUMENTS]: '#4D96FF',
  [ItemCategory.ELECTRONICS]: '#9B5DE5',
  [ItemCategory.TOILETRIES]: '#2EC4B6',
  [ItemCategory.MEDICINE]: '#F4A261',
  [ItemCategory.OTHER]: '#7A7A7A'
}

export function getTripTypeLabel(type: string): string {
  const option = TRIP_TYPE_OPTIONS.find((item: { value: string; label: string }) => item.value === type)
  return option ? option.label : '未分类'
}

export function getCategoryLabel(category: string): string {
  const option = CATEGORY_OPTIONS.find((item: { value: string; label: string }) => item.value === category)
  return option ? option.label : '其他'
}

export function getTripStatusLabel(status: string): string {
  const option = STATUS_OPTIONS.find((item: { value: string; label: string }) => item.value === status)
  return option ? option.label : '待出发'
}
