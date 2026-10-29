export enum WardrobeCategory {
  TOP = '上衣',
  BOTTOM = '下装',
  OUTER = '外套',
  SHOES = '鞋靴',
  ACCESSORY = '配饰'
}

export enum WardrobeSeason {
  SPRING = '春',
  SUMMER = '夏',
  AUTUMN = '秋',
  WINTER = '冬',
  ALL = '四季'
}

export class Clothing {
  id: number = -1
  name: string = ''
  category: string = WardrobeCategory.TOP
  colorName: string = ''
  season: string = WardrobeSeason.ALL
  imagePath: string = ''
  favorite: boolean = false
  createdAt: number = 0

  constructor(id: number, name: string, category: string, colorName: string,
    season: string, imagePath: string, favorite: boolean, createdAt: number) {
    this.id = id
    this.name = name
    this.category = category
    this.colorName = colorName
    this.season = season
    this.imagePath = imagePath
    this.favorite = favorite
    this.createdAt = createdAt
  }
}

export class Outfit {
  id: number = -1
  name: string = ''
  topId: number = -1
  bottomId: number = -1
  outerId: number = -1
  shoesId: number = -1
  accessoryId: number = -1
  createdAt: number = 0

  constructor(id: number = -1, name: string = '', topId: number = -1, bottomId: number = -1,
    outerId: number = -1, shoesId: number = -1, accessoryId: number = -1, createdAt: number = 0) {
    this.id = id
    this.name = name
    this.topId = topId
    this.bottomId = bottomId
    this.outerId = outerId
    this.shoesId = shoesId
    this.accessoryId = accessoryId
    this.createdAt = createdAt
  }
}

export class OutfitLog {
  id: number = -1
  outfitId: number = -1
  logDate: string = ''
  createdAt: number = 0

  constructor(id: number = -1, outfitId: number = -1, logDate: string = '', createdAt: number = 0) {
    this.id = id
    this.outfitId = outfitId
    this.logDate = logDate
    this.createdAt = createdAt
  }
}

export class OutfitView {
  outfit: Outfit = new Outfit()
  items: Clothing[] = []
  wearCount: number = 0
}

export class ChartItem {
  label: string = ''
  value: number = 0
  color: string = '#3E5C76'

  constructor(label: string = '', value: number = 0, color: string = '#3E5C76') {
    this.label = label
    this.value = value
    this.color = color
  }
}

export class ColorOption {
  name: string = ''
  hex: string = '#333333'

  constructor(name: string, hex: string) {
    this.name = name
    this.hex = hex
  }
}

export const WARDROBE_COLORS: ColorOption[] = [
  new ColorOption('黑', '#222222'),
  new ColorOption('白', '#F5F5F0'),
  new ColorOption('灰', '#9E9E9E'),
  new ColorOption('红', '#C62828'),
  new ColorOption('蓝', '#1E6BB8'),
  new ColorOption('绿', '#2E7D32'),
  new ColorOption('黄', '#E6A817'),
  new ColorOption('棕', '#6D4C2F'),
  new ColorOption('粉', '#E58FB1'),
  new ColorOption('紫', '#7B3FA0')
]

export function categoryValues(): string[] {
  return [WardrobeCategory.TOP, WardrobeCategory.BOTTOM, WardrobeCategory.OUTER,
    WardrobeCategory.SHOES, WardrobeCategory.ACCESSORY]
}

export function seasonValues(): string[] {
  return [WardrobeSeason.ALL, WardrobeSeason.SPRING, WardrobeSeason.SUMMER,
    WardrobeSeason.AUTUMN, WardrobeSeason.WINTER]
}

export function categoryEmoji(category: string): string {
  if (category === WardrobeCategory.TOP) {
    return '👕'
  } else if (category === WardrobeCategory.BOTTOM) {
    return '👖'
  } else if (category === WardrobeCategory.OUTER) {
    return '🧥'
  } else if (category === WardrobeCategory.SHOES) {
    return '👟'
  } else if (category === WardrobeCategory.ACCESSORY) {
    return '🧣'
  } else {
    return '🧺'
  }
}

export function toFileUri(path: string): string {
  if (path.startsWith('file://')) {
    return path
  }
  return 'file://' + path
}

export function pad2(n: number): string {
  return n < 10 ? '0' + n.toString() : n.toString()
}

export function toDateString(year: number, month: number, day: number): string {
  return `${year}-${pad2(month)}-${pad2(day)}`
}

export function todayDateString(): string {
  const d = new Date()
  return toDateString(d.getFullYear(), d.getMonth() + 1, d.getDate())
}

export function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate()
}

export function firstWeekdayOfMonth(year: number, month: number): number {
  const w = new Date(year, month - 1, 1).getDay()
  return w === 0 ? 6 : w - 1
}
