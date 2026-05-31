export type CareType = 'water' | 'fertilize' | 'prune' | 'repot'

export class CareRecord {
  id: number = 0
  plantId: number = 0
  careType: CareType = 'water'
  careDate: string = new Date().toISOString()
  note: string = ''

  constructor(source?: Partial<CareRecord>) {
    if (!source) {
      return
    }
    this.id = Number(source.id ?? this.id)
    this.plantId = Number(source.plantId ?? this.plantId)
    this.careType = (source.careType ?? this.careType) as CareType
    this.careDate = source.careDate ?? this.careDate
    this.note = source.note ?? this.note
  }

  static fromRow(row: Record<string, Object | number | string | null>): CareRecord {
    return new CareRecord({
      id: Number(row.id ?? 0),
      plantId: Number(row.plantId ?? 0),
      careType: String(row.careType ?? 'water') as CareType,
      careDate: String(row.careDate ?? new Date().toISOString()),
      note: String(row.note ?? '')
    })
  }

  getTypeLabel(): string {
    switch (this.careType) {
      case 'fertilize':
        return '施肥'
      case 'prune':
        return '修剪'
      case 'repot':
        return '换盆'
      default:
        return '浇水'
    }
  }
}
