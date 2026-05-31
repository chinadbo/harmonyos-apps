export class Plant {
  id: number = 0
  name: string = ''
  species: string = ''
  photoUri: string = ''
  addedDate: string = new Date().toISOString()
  waterInterval: number = 3
  fertilizeInterval: number = 30
  lastWateredAt: string = ''
  lastFertilizedAt: string = ''
  reminderId: number = 0
  notes: string = ''

  constructor(source?: Partial<Plant>) {
    if (!source) {
      return
    }
    this.id = Number(source.id ?? this.id)
    this.name = source.name ?? this.name
    this.species = source.species ?? this.species
    this.photoUri = source.photoUri ?? this.photoUri
    this.addedDate = source.addedDate ?? this.addedDate
    this.waterInterval = Number(source.waterInterval ?? this.waterInterval)
    this.fertilizeInterval = Number(source.fertilizeInterval ?? this.fertilizeInterval)
    this.lastWateredAt = source.lastWateredAt ?? this.lastWateredAt
    this.lastFertilizedAt = source.lastFertilizedAt ?? this.lastFertilizedAt
    this.reminderId = Number(source.reminderId ?? this.reminderId)
    this.notes = source.notes ?? this.notes
  }

  static fromRow(row: Record<string, Object | number | string | null>): Plant {
    return new Plant({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      species: String(row.species ?? ''),
      photoUri: String(row.photoUri ?? ''),
      addedDate: String(row.addedDate ?? new Date().toISOString()),
      waterInterval: Number(row.waterInterval ?? 3),
      fertilizeInterval: Number(row.fertilizeInterval ?? 30),
      lastWateredAt: String(row.lastWateredAt ?? ''),
      lastFertilizedAt: String(row.lastFertilizedAt ?? ''),
      reminderId: Number(row.reminderId ?? 0),
      notes: String(row.notes ?? '')
    })
  }

  private startOfDay(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate())
  }

  private addDays(base: Date, days: number): Date {
    const next = new Date(base.getTime())
    next.setDate(next.getDate() + days)
    return next
  }

  private parseDate(value: string): Date {
    if (!value || value.length === 0) {
      return new Date(this.addedDate)
    }
    return new Date(value)
  }

  getDisplayName(): string {
    if (this.species.length > 0) {
      return `${this.name} · ${this.species}`
    }
    return this.name
  }

  getNextWaterDate(): Date {
    const base = this.parseDate(this.lastWateredAt)
    return this.addDays(base, this.waterInterval)
  }

  getNextFertilizeDate(): Date {
    const base = this.parseDate(this.lastFertilizedAt)
    return this.addDays(base, this.fertilizeInterval)
  }

  isWaterDueToday(): boolean {
    return this.startOfDay(this.getNextWaterDate()).getTime() <= this.startOfDay(new Date()).getTime()
  }

  isFertilizeDue(): boolean {
    return this.startOfDay(this.getNextFertilizeDate()).getTime() <= this.startOfDay(new Date()).getTime()
  }

  getWaterStatusText(): string {
    if (this.isWaterDueToday()) {
      return '今日待浇水'
    }
    return `下次浇水 ${this.formatDate(this.getNextWaterDate())}`
  }

  getFertilizeStatusText(): string {
    if (this.isFertilizeDue()) {
      return '今日待施肥'
    }
    return `下次施肥 ${this.formatDate(this.getNextFertilizeDate())}`
  }

  formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
